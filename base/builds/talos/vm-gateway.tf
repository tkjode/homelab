
resource "tls_private_key" "gateway-ssh-key" {
  algorithm = "ED25519"
}

resource "proxmox_virtual_environment_file" "gateway-user-data-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node
  source_raw {
    file_name   = "talos-gateway-user-data.yaml"
    data        = templatefile(
                    "cloud-init/gateway/user-data.yaml",
                    {
                      host-ssh-key-ed25519 = tls_private_key.gateway-ssh-key
                    }
                  )
  }
}

resource "proxmox_virtual_environment_file" "gateway-network-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node
  source_raw {
    file_name   = "talos-gateway-network-config.yaml"
    data        = templatefile(
                    "cloud-init/router/network-config.yaml",
                    {
                      public_mac_addr      = var.gateway_mac_public
                      private_mac_addr     = var.gateway_mac_private
                    }
                  )
  }
}

resource "proxmox_virtual_environment_vm" "talos-gateway" {
  name              = "talos-gateway"
  vm_id             = 800
  description       = "Talos Gateway Router VM"
  tags              = ["talos", "gateway"]
  node_name         = var.proxmox_node
  stop_on_destroy   = true

  agent {
    enabled         = true
  }

  cpu {
    cores           = 2
    type            = "x86-64-v2-AES"
  }

  memory {
    dedicated       = 4096
    floating        = 4096
  }

  disk {
    datastore_id    = "SSD"
    file_id         = proxmox_download_file.linux-cloud-init-iso.id
    size            = 10
    interface       = "scsi0"
  }

  serial_device { }

  network_device {
    bridge          = local.home_bridge_id
    mac_address     = var.router_mac_public
  }

  network_device {
    bridge          = local.test_bridge_id
    mac_address     = var.router_mac_private
  }

  operating_system {
    type            = "l26"
  }

  initialization {
    datastore_id    = "cloudinit"

    user_data_file_id     = proxmox_virtual_environment_file.router-user-data-cloud-config.id
    network_data_file_id  = proxmox_virtual_environment_file.router-network-cloud-config.id
  }
}