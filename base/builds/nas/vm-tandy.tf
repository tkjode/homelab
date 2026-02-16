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

  usb {
    mapping = proxmox.virtual_environment_hardware_mapping_usb.terramaster.id
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

resource "proxmox_virtual_environment_hardware_mapping_usb" "terramaster" {
  comment = "USB3 Direct Attached Storage for NAS VM"
  name    = "terramaster"
  map     = [
              {
                id = "0480:a006"
                node = var.proxmox_node
              }
            ]
}

resource "proxmox_virtual_environment_file" "nas-user-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = "tandy-nas-user-data.yaml"
    data        = templatefile(
                    "cloud-init/nas-vm/cloud-user-data.yml.tftpl",
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