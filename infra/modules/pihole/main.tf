resource "kubernetes_namespace" "pihole-cloud" {
  metadata {
    name = "pihole-cloud"
  }
}

# define the ingress for pihole DNS service
# resource "kubernetes_manifest" "longhorn-networking" {
#   manifest = {
#     apiVersion = "traefik.containo.us/v1alpha1"
#     kind       = "IngressRoute"

#     metadata = {
#       name      = "pihole-dns"
#       namespace = "pihole-cloud"
#     }

#     spec = { 
#       entryPoints = [
#         "web"
#       ]

#       routes = [
#         {
#           match = "Host(`longhorn`)"
#           kind = "Rule"
#           services = [
#             {
#               name = "longhorn-frontend-ui"
#               namespace = "longhorn-system"
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

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
