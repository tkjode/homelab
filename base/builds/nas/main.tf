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

variable "proxmox_node" {
  description   = "The node name of the physical Proxmox host on which kubernetes VMs and networks will be deployed"
  type          = string
  default       = "proxmox"
}

variable "iso_datastore" {
  type          = string
  default       = "local"
}