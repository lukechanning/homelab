resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

resource "helm_release" "tailscale-deploy" {
  name       = "tailscale"
  namespace  = "tailscale"
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"

  set {
    name  = "oauth.clientId"
    value = var.tailscale_client_id  
  }

  set { 
    name  = "oauth.clientSecret"
    value = var.tailscale_client_secret
  }
}

