terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "talos/iso"
    region = "ca-central-1"
  }

}