terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "regulus/infrastructure"
    region = "ca-central-1"

  }

}

variable "proxmox_node" {
  type = string
}

variable "iso_datastore" {
  type = string
}
