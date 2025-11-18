terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
  }

  backend "s3" {
    bucket = "phalnet-homelab-automation"
    key = "regulus/infrastructure"
    region = "ca-central-1"
  }

}

variable "proxmox_node" {
  description = "The node name of the physical Proxmox host on which kubernetes VMs and networks will be deployed"
  type = string
  default = "proxmox"
}

variable "iso_datastore" {
  type = string
  default = "local"
}

variable "cluster_network_bridge" {
  description = "The bridge interface in Proxmox to house kubernetes node network"
  type = string
  default = "vmbr10"
}

variable "home_network_bridge" {
  description = "The bridge interface in Proxmox that physically binds to the internet-routable home network"
  type = string
  default = "vmbr0"
}