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

variable "openwrt_release_url" {
  type = string
}

variable "image_datastore" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "iso_datastore" {
  type = string
}

variable "talos_iso_version" {
  type = string
}