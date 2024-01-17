# Homelab Infrastructure as Code

## Prep:

Before you can actually `terraform apply` what's contained here, you will need to do a few things on the node(s). In order, they are:

### 1. Add required deps to each node

We need a few packages, sadly, to make everything work. Be sure to run this on each node:

`sudo apt install open-iscsi`

### 2. Modify traefik on the root node

Pop open `/var/lib/rancher/k3s/server/manifests/traefik-config.yaml` and add —

```
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      udp-dns:
        port: 5053
        expose: true
        exposedPort: 53
        protocol: UDP
      tcp-dns:
        port: 5054
        expose: true
        exposedPort: 53
        protocol: TCP
```
