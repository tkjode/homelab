resource "proxmox_virtual_environment_vm" "tandy" {
  name                  = "tandy"
  description           = "Home Network NAS"
  tags                  = [ "cloud-init", "debian" ]
  node_name             = var.proxmox_node
  stop_on_destroy       = true
  vm_id                 = 300

  agent {
    enabled             = true
  }

  cpu {
    cores               = 16
    type                = "x86-64-v2-AES"
  }

  memory {
    dedicated           = 32768
    floating            = 32768
  }

  disk {
    datastore_id        = "SSD"
    file_id             = proxmox_virtual_environment_download_file.debian-trixie.id
    size                = 25
    interface           = "scsi0"
  }

  disk {
    datastore_id        = ""
    file_format         = "raw"
    path_in_datastore   = "/dev/disk/by-uuid/ab0a1ecd-17ac-450a-b2e7-45683433c462"
    interface           = "scsi1"
  }

  network_device {
    bridge              = "vmbr0"
  }

  serial_device {}

  operating_system {
    type                = "l26"
  }

  initialization {
    datastore_id        = "cloudinit"

    dns {
      servers           = [ "1.1.1.1", "4.4.4.4" ]
    }

    ip_config {
      ipv4 {
        address         = "10.0.0.5/24"
        gateway         = "10.0.0.1"
      }
    }

    user_data_file_id   = proxmox_virtual_environment_file.nas-user-cloud-config.id

  }
}

resource "proxmox_virtual_environment_file" "nas-user-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = "bastion-user-data.yaml"
    data        = templatefile(
                    "cloud-init/nas-vm/cloud-user-data.yaml.tftpl",
                    {
                      nas-rsa     = tls_private_key.nas-rsa.private_key_pem
                      nas-ecdsa   = tls_private_key.nas-ecdsa.private_key_pem
                    }
                  )
  }
}

resource "tls_private_key" "nas-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "nas-ecdsa" {
  algorithm = "ECDSA"
}