variable "proxmox_endpoint_uri" {
  type          = string
  description   = "The full protocol+hostname+port+path URI to the Proxmox cluster JSON API"
  sensitive     = true
  nullable      = false
  
  validation {
    condition     = length(var.proxmox_endpoint_uri) > 8 && substr(var.proxmox_endpoint_uri,0,8) == "https://"
    error_message = "The Proxmox Endpoint URI must start with protocol - https://"
  }
}

# -- Only used by Telmate provider with pm_parallel=var.x - removed below
#variable "proxmox_parallelism" {
#  type = number
#  description = "How many actions to execute (eg. vm builds) at once"
#  default = 1
#}

variable "talos_version" {
  type        = string
  default     = "v1.9.1"
  description = "Talos ISO Download Path version - will save as a unique filename in proxmox as well"
}

variable "worker_count" {
  type        = number
  default     = 3
  description = "How many worker nodes to build"
  nullable    = false
}

variable "iso_datastore" {
  type    = string
  default = "local"
}

variable "vlan_number" {
  type        = number
  nullable    = false
  description = "VLAN number for the private cluster network"
  
  validation {
    condition     = var.vlan_number > 1 && var.vlan_number < 1024
    error_message = "VLANs must be between 2 and 1023 (inclusive)"
  }
}

variable "cluster" {
  type        = string
  description = "A short name for the cluster to use to append and differentiate resources"
  nullable    = false
}

variable "target_proxmox_node_name" {
  type        = string
  default     = "proxmox"
}

variable "nodesizing" {
  type = object({
    master = object({
      vcpu = number
      mem  = number
      })
    worker = object({
      vcpu = number
      mem  = number
    })
  })

  default = {
    master = {
      vcpu = 4
      mem  = 8192
    }
    worker = {
      vcpu = 4
      mem  = 8192
    }
  }
}