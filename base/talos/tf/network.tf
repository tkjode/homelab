resource "proxmox_virtual_environment_network_linux_vlan" "vlan100" {
  node_name = "proxmox"
  name = "talon-k8s-100"
  interface = "eno0"
  vlan = 100
}

resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  depends_on = [ 
    proxmox_virtual_environment_network_linux_vlan.vlan100
  ]
}

resource "proxmox_virtual_environment_vm" "gw-opnsense" {
  node_name = "proxmox"

  name = "gw-opnsense-${var.cluster}"

  tags = ["gateway", "talos"]
  
  startup {
    order=2
    up_delay=15
  }
  
  cpu {
    cores = 2
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating = 2048
  }

  disk {
    datastore_id = var.iso_datastore
    interface = "scsi0"

  }

  disk {
    datastore_id = "SSD"
    interface = "sata"
    size = 10
    ssd = "true"
  }

  initialization {
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
    bridge = proxmox_virtual_environment_network_linux_bridge.vmbr1.id
  }
}