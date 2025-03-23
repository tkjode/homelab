terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "proxmox/iso/talos"
    region = "ca-central-1"

  }
}