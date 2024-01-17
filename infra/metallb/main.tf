resource "kubernetes_namespace" "metallb-system" {
  metadata {
    name = "metallb-system"
  }
}

# import custom resource to defin IP range for metallb
resource "kubernetes_manifest" "metallb-config" {
  manifest = { 
    apiVersion  = "metallb.io/v1beta1"
    kind        = "IPAddressPool"

    metadata = {
      name      = "first-pool"
      namespace = "metallb-system"
    }

    spec = {
      addresses = [
        "192.168.1.10-192.168.1.50"
      ]
    }
  }
}

# define announcement protocol for metallb
resource "kubernetes_manifest" "metallb-config-protocol" {
  manifest = { 
    apiVersion  = "metallb.io/v1beta1"
    kind        = "L2Advertisement"

    metadata = {
      name      = "metallb-l2-config"
      namespace = "metallb-system"
    }

    spec = {
      ipAddressPools = ["first-pool"] 
    }
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb-system"
  chart      = "https://github.com/metallb/metallb/releases/download/metallb-chart-0.13.12/metallb-0.13.12.tgz"
  # repository = "https://metallb.github.io/metallb"
  # chart      = "metallb"
  # version    = "0.13.12"
}
