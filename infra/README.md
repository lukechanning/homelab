# Homelab Infrastructure as Code :zap:

## Prep:

Before you can actually `terraform apply` what's contained here, you will need to do a few things on the node(s). In order, they are:

### 1. Collect your variables

A number of locally defined variables are required to make everything work together. Be sure to collect all of the following and store them in `terraform.tfvars` at the `infra` root:

- `host` (The k8s host endpoint)
- `client_certificate`
- `client_key`
- `cluster_ca_certificate`
- `tailscale_client_id` (Configure a new OAuth provider in Tailscale and get client_id)
- `tailscale_client_secret` (Configure a new OAuth provider in Tailscale and get client_secret)

### 2. Add required deps to each node

We need a few packages, sadly, to make everything work. Be sure to run this on each node:

`sudo apt install open-iscsi`

## Tunneling Services:

Sometimes you need to expose a service to the broader world. Tailscale makes this pretty straightforward. Here's an example of doing it with a sample Ingress for the Pi-hole service: 

```
resource "kubernetes_manifest" "ingress_pihole_web" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "tailscale.com/funnel" = "true"
      }
      "name" = "pihole-web"
      "namespace" = "pihole-cloud"
    }
    "spec" = {
      "defaultBackend" = {
        "service" = {
          "name" = "pihole-web"
          "port" = {
            "number" = 80
          }
        }
      }
      "ingressClassName" = "tailscale"
      "tls" = [
        {
          "hosts" = [
            "pihole-web",
          ]
        },
      ]
    }
  }
}
```
