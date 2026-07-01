terraform {
  required_providers {
    proxmox = {
      source    = "bpg/proxmox"
      version   = "0.104.0"
    }
  }

  backend "s3" {
    bucket      = "phalnet-homelab-automation"
    key         = "homelab-router/test"
    region      = "ca-central-1"
  }
}