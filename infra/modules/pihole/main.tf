resource "kubernetes_namespace" "pihole-cloud" {
  metadata {
    name = "pihole-cloud"
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
