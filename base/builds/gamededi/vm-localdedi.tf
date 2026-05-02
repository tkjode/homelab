resource "proxmox_virtual_environment_vm" "persistent-disk-stub-localdedi" {
  node_name                 = var.proxmox_node
  tags                      = ["gaming"]
  started                   = false
  on_boot                   = false
  vm_id                     = 303
  description               = "Persistent 256GB Disk for Gaming Server"
  protection                = true

  disk {
    datastore_id            = "SSD"
    interface               = "scsi0"
    size                    = 256
  }
}

### Actual VM -----------------------------------------------------------

resource "proxmox_virtual_environment_vm" "localdedi" {
  name                      = "localdedi"
  description               = "Docker Dedicated Gaming VM"
  tags                      = ["gaming", "cloud-init"]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true
  vm_id                     = 304

  agent {
    enabled                 = true
  }

  cpu {
    cores                   = 4
    numa                    = true
    sockets                 = 2
    type                    = "x86-64-v2-AES"
  }

  memory {
    dedicated               = 16384
    floating                = 16384
  }

  # Boot Disk
  disk {
    datastore_id            = "SSD"
    file_id                 = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                    = 25
    interface               = "scsi0"
  }

  # Attached Disk
  dynamic "disk" {
    for_each                = { for idx, val in proxmox_virtual_environment_vm.persistent-disk-stub-localdedi.disk : idx => val }
    iterator                = data_disk
    content {
        datastore_id        = data_disk.value["datastore_id"]
        path_in_datastore   = data_disk.value["path_in_datastore"]
        file_format         = data_disk.value["file_format"]
        size                = data_disk.value["size"]
        interface           = "scsi${data_disk.key + 1}"
    }
  }

  serial_device { }

  network_device {
    bridge                  = "vmbr0"
  }

  operating_system {
    type                    = "l26"
  }

  initialization {
    datastore_id            = "cloudinit"
    dns {
      servers               = [ "1.1.1.1" ,"4.4.4.4" ]
      domain                = "homenet.phalnet.com"
    }
    ip_config {
      ipv4 {
        address             = "10.0.0.11/24"
        gateway             = "10.0.0.1"
      }
    }

    user_data_file_id       = proxmox_virtual_environment_file.localdedi-cloud-user-data.id

  }
}

resource "proxmox_virtual_environment_file" "localdedi-cloud-user-data" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = "localdedi-user-cloud-data.yaml"
    data        = templatefile(
                    "cloud-init/localdedi-vm/cloud-user-data.yml.tftpl",
                    {
                      hostname = "localdedi",
                      host-ssh-key-ed25519  = tls_private_key.localdedi-ssh-ed25519
                    }
                  )
  }
}

resource "tls_private_key" "localdedi-ssh-ed25519" {
  algorithm = "ED25519"
}