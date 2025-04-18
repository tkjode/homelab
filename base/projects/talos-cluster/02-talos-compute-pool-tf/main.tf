terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = var.bpg_provider_version
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "talos/pool"
    region = "ca-central-1"

  }

}