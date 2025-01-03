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

variable "proxmox_parallelism" {
  type = number
  description = "How many actions to execute (eg. vm builds) at once"
  default = 1
}

variable "workers" {
  type = number
  default = 3
  description = "How many worker nodes to build"
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
      mem = 8
    }
    worker = {
      vcpu = 4
      mem = 8
    }
  }

}

provider "proxmox" {
  endpoint = var.proxmox_endpoint_uri
  pm_parallel = var.proxmox_parallelism
}

resource "proxmox_virtual_environment_pool" "talon-k8s" {
  pool_id = "talon-k8s"
  comment = "TALON: Kubernetes with Talos VM"
}