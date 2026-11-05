terraform {
  required_providers {
    proxmox = {
      source    = "bpg/proxmox"
      version   = "0.120.0"
    }
  }

  backend "s3" {
    bucket      = "phalnet-homelab-automation"
    key         = "talos/main"
    region      = "ca-central-1"
  }
}