################
# CLUSTER VARS #
################

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

################
# SERVICE VARS #
################

variable "tailscale_client_id" {
  type = string
}

variable "tailscale_client_secret" {
  type = string
}


