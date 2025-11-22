resource "proxmox_virtual_environment_vm" "bastion" {
  name        = "bastion"
  description = "Regulus Bastion Hacking Machine"
  tags        = [ "regulus", "cloud-init", "ubuntu" ]
  node_name   = var.proxmox_node
  stop_on_destroy = true

  depends_on = [ proxmox_virtual_environment_vm.regulus-gateway ]

  agent {
    enabled = false
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
    floating  = 1024
  }

  disk {
    datastore_id  = "SSD"
    file_id       = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size          = 10
    interface     = "scsi0"
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.proxmox-cluster-bridge.name
  }

  serial_device {}

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "cloudinit"

    dns {
      domain = "apps.phalnet.com"
      servers = [ "1.1.1.1", "4.4.4.4" ]
    }

    ip_config {
      ipv4 {
        address = "192.168.64.2/24"
        gateway = "192.168.64.1"
      }
    }

    user_account {
      username = "debug"
      password = "debug"
    }

  }

}