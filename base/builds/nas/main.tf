terraform {
  required_providers {
    proxmox = {
      source    = "bpg/proxmox"
      version   = "0.86.0"
    }
  }

  backend "s3" {
    bucket      = "phalnet-homelab-automation"
    key         = "homelab-vm/nas"
    region      = "ca-central-1"
  }
}