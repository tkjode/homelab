terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "talos/network"
    region = "ca-central-1"

  }

}

variable "talos_vlan" {
  type = number
}

variable "proxmox_node" {
  type = string
}
