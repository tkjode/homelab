terraform {
  required_providers {
    proxmox={
      source="Telmate/proxmox"
      version="3.0.1-rc4"
    }
  }
}

variable "proxmox_endpoint_uri" {
  type = string
  description = "The full protocol+hostname+port+path URI to the Proxmox cluster JSON API"
  sensitive = true
  nullable = false
  validation {
    condition = length(var.proxmox_endpoint_url) > 8 && substr(var.proxmox_endpoint_uri,0,8) == "https://"
    error_message = "The Proxmox Endpoint URI must start with protocol - https://"
  }
}

variable "proxmox_parallelism" {
  type = number
  description = "How many actions to execute (eg. vm builds) at once"
  default = 1
}

provider "proxmox" {
  pm_api_url = var.proxmox_endpoint_uri
  pm_parallel = var.proxmox_parallelism
}