resource "proxmox_virtual_environment_vm" "cloud-init-test" {
  name        = "bastion-test"
  description = "ProxMox Private Network Routing Test"
  tags        = [ "lab", "cloud-init", "ubuntu" ]
  node_name   = var.proxmox_node
  stop_on_destroy = true

  agent {
    enabled = true
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
    bridge = "vmbr1"
  }

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
        address = "192.168.64.5/24"
        gateway = "192.168.64.1"
      }
    }

    user_account {
      username = "debug"
      password = "debug"
    }

  }

}