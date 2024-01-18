resource "kubernetes_namespace" "cloudflare" {
  metadata {
    name = "cloudflare"
  }
}

resource "kubernetes_secret" "tunnel-credentials" {
  metadata {
    name      = "tunnel-credentials"
    namespace = "cloudflare"
  }
  type = "Opaque"
  data = {
    "credentials.json" = file("${path.module}/credentials.json")
  } 
}

resource "kubernetes_manifest" "cloudflared-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "cloudflared"
      "namespace" = "cloudflare"
    }
    "spec" = {
      "replicas" = 2
      "selector" = {
        "matchLabels" = {
          "app" = "cloudflared"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "cloudflared"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "tunnel",
                "--config",
                "/etc/cloudflared/config/config.yaml",
                "run",
              ]
              "image" = "cloudflare/cloudflared:latest-arm64"
              "livenessProbe" = {
                "failureThreshold" = 1
                "httpGet" = {
                  "path" = "/ready"
                  "port" = 2000
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
              }
              "name" = "cloudflared"
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/cloudflared/config"
                  "name" = "config"
                  "readOnly" = true
                },
                {
                  "mountPath" = "/etc/cloudflared/creds"
                  "name" = "creds"
                  "readOnly" = true
                },
              ]
            },
          ]
          "volumes" = [
            {
              "name" = "creds"
              "secret" = {
                "secretName" = "tunnel-credentials"
              }
            },
            {
              "configMap" = {
                "items" = [
                  {
                    "key" = "config.yaml"
                    "path" = "config.yaml"
                  },
                ]
                "name" = "cloudflared"
              }
              "name" = "config"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "cloudflared-configmap-deploy" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "cloudflared"
      "namespace" = "cloudflare"
    }
    "data" = {
      "config.yaml" = <<-EOT
      # Name of the tunnel you want to run
      tunnel: homelab-tunnel 
      credentials-file: /etc/cloudflared/creds/credentials.json
      # Serves the metrics server under /metrics and the readiness server under /ready
      metrics: 0.0.0.0:2000
      no-autoupdate: true
      ingress:
      - hostname: pihole.bitfoot.cloud
        service: http://192.168.1.16:80 
      # This rule matches any traffic which didn't match a previous rule, and responds with HTTP 404.
      - service: http_status:404
      EOT
    }
  }
}

