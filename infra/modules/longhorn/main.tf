## FOR THIS TO WORK: #################################
## 1. Each node must have open-iscsi installed #######
## $ sudo apt install open-iscsi #####################
######################################################
resource "kubernetes_namespace" "longhorn-system" {
  metadata {
    name = "longhorn-system"
  }
}

# define the longhorn-frontend-ui service to use with ingress
resource "kubernetes_service" "longhorn-frontend-ui" {
  metadata {
    name = "longhorn-frontend-ui"
    namespace = "longhorn-system"
  }
  spec {
    selector = {
      app = "longhorn-ui" 
    }
    port {
      port = 80
      # target_port = 80
    }
  }
}

resource "kubernetes_manifest" "longhorn-networking" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "longhorn-ui"
      namespace = "longhorn-system"
    }

    spec = { 
      entryPoints = [
        "web"
      ]

      routes = [
        {
          match = "Host(`longhorn`)"
          kind = "Rule"
          services = [
            {
              name = "longhorn-frontend-ui"
              namespace = "longhorn-system"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  namespace  = "longhorn-system"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.5.3"
}
