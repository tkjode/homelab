terraform {
  required_providers {
    proxmox = {
      source    = "bpg/proxmox"
      version   = "0.86.0"
    }
  }

  backend "s3" {
    bucket      = "phalnet-homelab-automation"
    key         = "regulus/infrastructure"
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

variable "cluster_network_bridge" {
  description   = "The bridge interface in Proxmox to house kubernetes node network"
  type          = string
  default       = "vmbr10"
}

variable "home_network_bridge" {
  description   = "The bridge interface in Proxmox that physically binds to the internet-routable home network"
  type          = string
  default       = "vmbr0"
}

variable "nameservers" {
  description   = "Where the router and nodes will be configured to query DNS"
  type          = list(string)
  default       = ["1.1.1.1", "4.4.4.4"]
}

variable "gw_hostname" {
  description   = "VM hostname for the Gateway VM"
  type          = string
  default       = "gateway"
}

variable "gw_net_home" {
  description   = "How to configure ethernet for home network connection"
  type          = object({
                    network   = string   # 10.0.0.0
                    mask      = number   # 24
                    cidr      = number   # 10   (cidrhost)
                    gateway   = number   # 1    (cidrhost)
                    mac       = string   # aa:bb:cc:dd:ee:ff
                  })
  default       = {
                    network   = "10.0.0.0"
                    mask      = "24"
                    cidr      = 10
                    gateway   = 1
                    mac       = "bc:24:11:d0:6e:75"
                  }
}

variable "gw_net_cluster" {
  description   = "How to configure ethernet for cluster private network connection"
  type          = object({
                    network   = string   # 192.168.64.0
                    mask      = number   # 24
                    cidr      = number   # 1 (cidrhost)
                    mac       = string   # aa:bb:cc:dd:ee:ff
                  })
  default       = {
                    network   = "192.168.64.0"
                    mask      = 24
                    cidr      = 1
                    mac       = "bc:24:11:ee:6e:75"
                  }
}

variable master_ip_offset {
  description = "IP Address Offset to assign 3 Master Nodes on the private network"
  type        = number
  default     = 4    # 192.168.64.4 to 6
}

variable worker_ip_offset {
  description = "IP Addresses Offset to start assigning Worker nodes on private network"
  type        = number
  default     = 8    # 192.168.64.8 to 14
}

variable worker_count {
  description = "How many worker nodes should be deployed to the private network"
  type        = number
  default     = 6
}