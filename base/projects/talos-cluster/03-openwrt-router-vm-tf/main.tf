terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.76.0"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "talos/openwrt"
    region = "ca-central-1"

  }

}

provider "proxmox" {
  ssh {
    node {
      name    = var.target_proxmox_node_name
      address = var.target_proxmox_node_ipaddr
    }
  }
}