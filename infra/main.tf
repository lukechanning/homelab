terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

###########
# MODULES #
###########
module "metallb-module" {
    source = "./modules/metallb"
}

module "longhorn-module" {
    source = "./modules/longhorn"
}

module "pihole-module" {
    source = "./modules/pihole"
}

module "cloudflare-module" {
    source = "./modules/cloudflare"
}

module "wireguard-module" {
    source = "./modules/wireguard"
}
