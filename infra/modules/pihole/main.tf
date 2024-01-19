resource "kubernetes_namespace" "pihole-cloud" {
  metadata {
    name = "pihole-cloud"
  }
}

# define the ingress for pihole web service
resource "kubernetes_manifest" "pihole-web-networking" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "pihole-external-web"
      namespace = "pihole-cloud"
    }

    spec = { 
      entryPoints = [
        "web"
      ]

      routes = [
        {
          match = "Host(`pihole`)"
          kind = "Rule"
          services = [
            {
              name = "pihole-web"
              namespace = "pihole-cloud"
              port = 80 
            }
          ]
        }
      ]
    }
  }
}

resource "helm_release" "pihole" {
  name       = "pihole"
  namespace  = "pihole-cloud"
  repository = "https://mojo2600.github.io/pihole-kubernetes"
  chart      = "pihole"
  version    = "2.21.0"
  values = [
    file("${path.module}/values.yaml"),
  ]
}
