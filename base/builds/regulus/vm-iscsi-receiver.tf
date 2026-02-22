resource "proxmox_virtual_environment_vm" "persistent-disk-stub" {
  node_name                 = var.proxmox_node
  tags                      = [var.cluster-name, "storage", "kubernetes"]
  pool_id                   = proxmox_virtual_environment_pool.cluster.pool_id
  started                   = false
  on_boot                   = false
  vm_id                     = var.proxmox-vmid-offset + var.worker-ip-offset + var.worker-count + 1
  description               = "Persistent 1TB Disk Stub"
  protection                = true

  disk {
    datastore_id            = "SSD"
    interface               = "scsi0"
    size                    = 1024
  }
}

### Actual VM -----------------------------------------------------------

resource "proxmox_virtual_environment_vm" "iscsi-receiver" {
  name                      = join("-", [var.cluster-name, "iscsi"])
  description               = "ISCSI Persistent Storage Provider"
  tags                      = [var.cluster-name, "storage", "kubernetes"]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true
  vm_id                     = var.proxmox-vmid-offset + var.iscsi-ip-offset

  pool_id                   = proxmox_virtual_environment_pool.cluster.pool_id

  depends_on                = [proxmox_virtual_environment_vm.regulus-gateway]

  agent {
    enabled                 = true
  }

  cpu {
    cores                   = 4
    type                    = "x86-64-v2-AES"
  }

  memory {
    dedicated               = 2048
    floating                = 2048
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
    for_each                = { for idx, val in proxmox_virtual_environment_vm.persistent-disk-stub.disk : idx => val }
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
    bridge                  = proxmox_virtual_environment_network_linux_bridge.proxmox-cluster-bridge.name
  }

  operating_system {
    type                    = "l26"
  }

  initialization {
    datastore_id            = "cloudinit"
    dns {
      servers               = var.nameservers
      domain                = join(".", [var.cluster-name, var.cluster-domain])
    }
    ip_config {
      ipv4 {
        address             = join("/", [ cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.iscsi-ip-offset), var.gw-net-cluster.mask ])
        gateway             = cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr)
      }
    }

    user_data_file_id       = proxmox_virtual_environment_file.iscsi-receiver-user-data-cloud-config.id

  }
}

resource "proxmox_virtual_environment_file" "iscsi-receiver-user-data-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = join("-", [var.cluster-name, "iscsi-receiver-config.yaml"] )
    data        = templatefile(
                    "cloud-init/iscsi-receiver/iscsi-receiver-config.yaml.tftpl",
                    {
                      hostname = join("-", [var.cluster-name, "iscsi"] ),
                      host-ssh-key-ed25519  = tls_private_key.iscsi-ssh-ed25519
                    }
                  )
  }
}

resource "tls_private_key" "iscsi-ssh-ed25519" {
  algorithm = "ED25519"
}