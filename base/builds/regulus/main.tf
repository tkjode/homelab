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

variable "cluster-network-bridge" {
  description   = "The bridge interface in Proxmox to house kubernetes node network"
  type          = string
  default       = "vmbr10"
}

variable "home-network-bridge" {
  description   = "The bridge interface in Proxmox that physically binds to the internet-routable home network"
  type          = string
  default       = "vmbr0"
}

variable "nameservers" {
  description   = "Where the router and nodes will be configured to query DNS"
  type          = list(string)
  default       = ["1.1.1.1", "4.4.4.4"]
}

variable "gw-hostname" {
  description   = "VM hostname for the Gateway VM"
  type          = string
  default       = "gateway"
}

variable "gw-net-home" {
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

variable "gw-net-cluster" {
  description   = "How to configure ethernet for cluster private network connection"
  type          = object({
                    network   = string   # 192.168.64.0
                    mask      = number   # 24
                    cidr      = number   # 1 (cidrhost)
                    mac       = string   # aa:bb:cc:dd:ee:ff
                  })
  default       = {
                    network   = "192.168.64.0"
                    mask      = "24"
                    cidr      = 1
                    mac       = "bc:24:11:ee:6e:75"
                  }
}

variable "master-ip-offset" {
  description = "IP Address Offset to assign 3 Master Nodes on the private network"
  type        = number
  default     = 4    # 192.168.64.4 to 6
}

variable "worker-ip-offset" {
  description = "IP Addresses Offset to start assigning Worker nodes on private network"
  type        = number
  default     = 8    # 192.168.64.8 to 14
}

variable "worker-count" {
  description = "How many worker nodes should be deployed to the private network"
  type        = number
  default     = 6
}

variable "pod-network" {
  description = "CIDR of internal Kubernetes Pod network (eg. 10.244.0.0/16) (< flannel default)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "service-network" {
  description = "CIDR of internal Kubernetes Service network (eg. 10.96.0.0/16)"
  type        = string
  default     = "10.96.0.0/16"
}

variable "cluster-join-token" {
  description = "The token used to join nodes to the cluster"
  type        = string
  default     = "123456.1234567890abcdef"
}

variable "cluster-name" {
  description = "Simple name of the cluster being created (will be appended to some DNS/Certs"
  type        = string
  default     = "regulus"
}

variable "cluster-domain" {
  description = "DNS Domain Suffix to be applied to cluster identity (not neccessarily the app gateway)"
  type        = string
  default     = "phalnet.com"
}

variable "argocd-ssh-private-key" {
  description = "Base64 Encoded Secret containing SSH Private Key allowing ArgoCD access to bootstrap repository"
  type        = "string"
}

variable "repository-url" {
  description = "Where ArgoCD will access for bootstrap manifests"
  type        = "string"
  default     = "ssh://git@github.com/tkjode/homelab"
}