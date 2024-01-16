resource "kubernetes_namespace" "metallb-system" {
  metadata {
    name = "metallb-system"
  }
}

resource "kubernetes_config_map" "metallb-config" {
  metadata {
    name = "metallb-config"
    namespace = "metallb-system"
  }
  data = {
    "config.yml" = "${file("${path.module}/config.yml")}"
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
