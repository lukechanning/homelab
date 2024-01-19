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
