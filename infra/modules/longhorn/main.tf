## FOR THIS TO WORK: #################################
## 1. Each node must have open-iscsi installed #######
## $ sudo apt install open-iscsi #####################
######################################################
resource "kubernetes_namespace" "longhorn-system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "kubernetes_service" "longhorn-secure" {
  metadata {
    name = "longhorn-secure"
    namespace = "longhorn-system"
    annotations = {
      "metallb.universe.tf/ip-allocated-from-pool" = "first-pool"
      "tailscale.com/expose" = "true"
      "tailscale.com/hostname" = "longhorncloud"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "longhorn-ui"
    }

    port {
      name = "http"
      port = 80 
      target_port = "http" 
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
