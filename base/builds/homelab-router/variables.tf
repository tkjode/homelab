variable "vm_boot_image" {
  type = string
  description = "URL to download a cloud-init enabled ISO image"
  nullable = false
  sensitive = false
  ephemeral = false
}

variable "bridge_id_private" {
  type = number
  description = "Appends to vmbr to create a unique private network in Proxmox"
}

variable "bridge_id_public" {
  type = number
  description = "Appends to vmbr to attach to an existing network in Proxmox (eg. internet routable physical home network)"
}

variable "proxmox_node" {
  type = string
}

variable "router_mac_private" {
  type = string
}

variable "router_mac_public" {
  type = string
}