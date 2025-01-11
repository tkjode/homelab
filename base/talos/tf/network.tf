## Networking Resources

resource "proxmox_virtual_environment_network_linux_vlan" "talos-vlan" {
  node_name   = var.target_proxmox_node_name
  name        = "eno2.${ var.vlan_number }"
  comment     = "VLAN ${ var.vlan_number } for ${ var.cluster }"
  interface   = "eno2"
  vlan        = var.vlan_number
}

resource "proxmox_virtual_environment_network_linux_bridge" "cluster-private-bridge" {
  node_name   = var.target_proxmox_node_name
  name        = "vmbr${ var.vlan_number }"

  depends_on = [
    proxmox_virtual_environment_network_linux_vlan.talos-vlan
  ]
}

resource "proxmox_virtual_environment_vm" "gw-opnsense" {
  node_name   = "proxmox"
  name        = "gw-opnsense-${ var.cluster }"
  tags        = [ "gateway", "talos", var.cluster ]

  startup {
    order     = 2
    up_delay  = 15
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  cdrom {
    enabled       = true
    file_id       = "${ var.iso_datastore }:iso/OPNSense.vga.iso"
  }

  disk {
    datastore_id  = "SSD"
    interface     = "scsi0"
    size          = 10
    ssd           = "true"
  }

  initialization {
    datastore_id  = "cloudinit"
    ip_config {
      ipv4 {
        address = "172.16.1.1/24"
        gateway = "172.16.1.1"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.cluster-private-bridge.name
  }
}