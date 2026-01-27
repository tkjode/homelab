terraform {
  required_providers {
    proxmox = {
      source    = "bpg/proxmox"
      version   = "0.93.0"
    }
  }

  backend "s3" {
    bucket      = "phalnet-homelab-automation"
    key         = "regulus/infrastructure"
    region      = "ca-central-1"
  }
}

variable "certbot_aws_access_key" {
  description   = "AWS Access Key ID to be used by CERTBOT, ideally should have a Route53 management-only role for the zone in use"
  type          = string
}

variable "certbot_aws_secret_key" {
  description   = "AWS Secret Key to be used by CERTBOT, associated with the Certbot AWS Access Key"
  type          = string
}

variable "certbot_contact_email" {
  description   = "E-Mail to use when registering ACME/EFF Account"
  type          = string
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
  description   = "Where the nodes will be configured to query DNS"
  type          = list(string)
  default       = ["192.168.64.1"]
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

variable "default-ingress-prefix" {
  description = "The Wildcard + Ingress Prefix to register with Certbot and expose in Envoy (eg. *.apps.domain.com)"
  type        = string
  default     = "apps"
}

variable "cluster-domain" {
  description = "DNS Domain Suffix to be applied to cluster identity (not neccessarily the app gateway)"
  type        = string
  default     = "_local"
}

variable "argocd-ssh-private-key" {
  description = "Base64 Encoded Secret containing SSH Private Key allowing ArgoCD access to bootstrap repository"
  type        = string
}

variable "repository-url" {
  description = "Where ArgoCD will access for bootstrap manifests"
  type        = string
  default     = "ssh://git@github.com/tkjode/homelab"
}

variable "proxmox-vmid-offset" {
  description = "Starting vmid for this cluster (eg. 200)"
  type        = number
  default     = 200
}

variable "kubernetes-version" {
  description = "Value from https://dl.k8s.io/release/stable.txt"
  type        = string
  default     = "v1.35"
}

variable "letsencrypt-storage" {
  description = "Object containing the NFS Mount Data for the LetsEncrypt folder"
  type        = object({
                  fs_spec     = string
                  fs_file     = string
                  fs_vfstype  = string
                  fs_mntopts  = string
                  fs_freq     = string
                  fs_passno   = string
                })
  default     = {
                  fs_spec     = "10.0.0.5:/srv/nas/gateway/letsencrypt"
                  fs_file     = "/etc/letsencrypt"
                  fs_vfstype  = "nfs"
                  fs_mntopts  = "defaults,_netdev"
                  fs_freq     = "0"
                  fs_passno   = "0"
                }
}