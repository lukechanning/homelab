## FOR THIS TO WORK: #################################
## 1. Each node must have open-iscsi installed #######
## 2. Helm chart must be added locally - see:  #######
## helm repo add longhorn https://charts.longhorn.io #
######################################################
resource "kubernetes_namespace" "longhorn-system" {
  metadata {
    name = "longhorn-system"
  }
}

# resource "kubernetes_manifest" "longhorn-networking" {
#   manifest = {
#     apiVersion = "traefik.containo.us/v1alpha1"
#     kind       = "IngressRoute"

#     metadata = {
#       name      = "longhorn-ui"
#       namespace = "longhorn-system"
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
#               kind = "Service"
#               name = "longhorn-frontend"
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

resource "helm_release" "longhorn" {
  name       = "longhorn"
  namespace  = "longhorn-system"
  chart      = "longhorn/longhorn"
  version    = "1.5.3"
}
