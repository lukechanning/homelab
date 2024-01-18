resource "kubernetes_namespace" "wireguard" {
  metadata {
    name = "wireguard"
  }
}

resource "kubernetes_secret" "wireguard-configmap" {
  metadata {
    name = "wireguard"
    namespace = "wireguard"
  }
  type = "Opaque"
  data = {
      "wg0.conf.template" = <<-EOT
      [Interface]
      Address = 192.168.1.11 
      ListenPort = 51820
      PrivateKey = mLNVWjpoynxJooivVnjlI/lkCJ2Xv0XhFeIA6jpRp2g=
      PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      PostUp = sysctl -w -q net.ipv4.ip_forward=1
      PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
      PostDown = sysctl -w -q net.ipv4.ip_forward=0
      
      [Peer]
      PublicKey = PbZiUWKa+2q4jd7uYsEZtjDUZXJVspocsaHemA7G8B4= 
      AllowedIPs = 192.168.2.3/32 
      EOT
    }
}

resource "kubernetes_service" "wireguard-service" {
  metadata {
    name = "wireguard-service"
    namespace = "wireguard"
    annotations = {
      "metallb.universe.tf/ip-allocated-from-pool" = "first-pool"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "wireguard"
    }
    port {
      port = 51820 
      target_port = 51820
      protocol = "UDP"
    }
  }
}

resource "kubernetes_manifest" "wireguard-deploy" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "wireguard"
      "namespace" = "wireguard"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "wireguard"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "wireguard"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "PUID"
                  "value" = "1000"
                },
                {
                  "name" = "PGID"
                  "value" = "1000"
                },
              ]
              "image" = "linuxserver/wireguard:latest"
              "name" = "wireguard"
              "ports" = [
                {
                  "containerPort" = 51820
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_ADMIN",
                    "SYS_MODULE",
                  ]
                }
                "privileged" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/config/"
                  "name" = "wireguard-config"
                },
                {
                  "mountPath" = "/etc/wireguard-secret/"
                  "name" = "wireguard-secret"
                },
              ]
            },
          ]
          "imagePullSecrets" = [
            {
              "name" = "docker-registry"
            },
          ]
          "initContainers" = [
            {
              "command" = [
                "sh",
                "-c",
                "mkdir /config/wg_confs; cp /etc/wireguard-secret/wg0.conf.template /config/wg_confs/wg0.conf; chmod 400 /config/wg_confs/wg0.conf",
                "sysctl -w net.ipv4.ip_forward=1",
              ]
              "image" = "busybox"
              "name" = "wireguard-template-replacement"
              "volumeMounts" = [
                {
                  "mountPath" = "/config/"
                  "name" = "wireguard-config"
                },
                {
                  "mountPath" = "/etc/wireguard-secret/"
                  "name" = "wireguard-secret"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "wireguard-config"
            },
            {
              "name" = "wireguard-secret"
              "secret" = {
                "secretName" = "wireguard"
              }
            },
          ]
        }
      }
    }
  }
}
