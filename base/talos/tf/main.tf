terraform {
  required_providers {
    proxmox={
      source="bpg/proxmox"
      version="0.69.0"
    }
  }
}

variable "proxmox_endpoint_uri" {
  type = string
  description = "The full protocol+hostname+port+path URI to the Proxmox cluster JSON API"
  sensitive = true
  nullable = false
  validation {
    condition = length(var.proxmox_endpoint_uri) > 8 && substr(var.proxmox_endpoint_uri,0,8) == "https://"
    error_message = "The Proxmox Endpoint URI must start with protocol - https://"
  }
}

# -- Only used by Telmate provider with pm_parallel=var.x - removed below
#variable "proxmox_parallelism" {
#  type = number
#  description = "How many actions to execute (eg. vm builds) at once"
#  default = 1
#}

variable "workers" {
  type = number
  default = 3
  description = "How many worker nodes to build"
}

variable "iso_datastore" {
  type = string
  default = "local"
}

variable "target_proxmox_node_name" {
  type = string
  default = "proxmox"
}

variable "nodesizing" {
  type = object({
    master=object({
      vcpu=number
      mem=number
      })
    worker=object({
      vcpu=number
      mem=number
    })
  })

  default = {
    master = {
      vcpu = 4
      mem = 8192
    }
    worker = {
      vcpu = 4
      mem = 8192
    }
  }

}

provider "proxmox" {
  endpoint = var.proxmox_endpoint_uri
}

resource "proxmox_virtual_environment_pool" "talon-k8s" {
  pool_id = "talon-k8s"
  comment = "TALON: Kubernetes with Talos VM"
}

resource "proxmox_virtual_environment_download_file" "talos-metal-image" {
  content_type = "iso"
  datastore_id = var.iso_datastore
  node_name = var.target_proxmox_node_name
  url = "https://github.com/siderolabs/talos/releases/download/v1.9.1/metal-amd64.iso"
}

resource "proxmox_virtual_environment_vlan" "snurt" {

}

resource "proxmox_virtual_environment_bridge" "sneep" {

}

resource "proxmox_virtual_environment_vm" "pfSense-GW" {

}

resource "proxmox_virtual_environment_vm" "masters" {
  count = 3
  node_name = "talon-master-${count.index}"
  tags = [ "kubernetes", "talos" ]
  pool_id = "talon-k8s"

  startup {
    order=5
    up_delay=15
    down_delay=15
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.nodesizing.master.vcpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.master.mem
    floating = var.nodesizing.master.mem
  }

  disk {
    datastore_id = "SSD"
    interface = "sata"
    size = 40
    ssd = "true"
  }

#  initialization {
#
#  }
}

resource "proxmox_virtual_environment_vm" "workers" {
  count = var.workers
  node_name = "talon-worker-${count.index}"
  startup {
    order = 10
    up_delay = 5
    down_delay = 5
  }
  agent {
    enabled=false
  }

  cpu {
    cores = var.nodesizing.worker.vcpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.worker.mem
    floating = var.nodesizing.worker.mem
  }

  disk {
    datastore_id = "SSD"
    interface = "sata"
    size = 40
    ssd = true
  }

# initialization {
#
#  }

}