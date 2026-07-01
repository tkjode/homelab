locals {
  home_bridge_id = join("", [ "vmbr", var.bridge_id_public ])
  test_bridge_id = join("", [ "vmbr", var.bridge_id_private ])
}

resource "proxmox_network_linux_bridge" "test-bridge" {
  node_name   = var.proxmox_node
  name        = local.test_bridge_id
  autostart   = true
  vlan_aware  = false
  comment     = "Cloud-Init Router Testing Bridge"
}

resource "proxmox_download_file" "linux-cloud-init-iso" {
  content_type          = "iso"
  datastore_id          = "local"
  overwrite_unmanaged   = true
  overwrite             = false
  file_name             = "ubuntu-cloud-server-amd64.iso"
  node_name             = var.proxmox_node
  url                   = var.vm_boot_image
}

################# Router Virtual Machine ##

resource "tls_private_key" "router-ssh-key" {
  algorithm = "ED25519"
}

resource "proxmox_virtual_environment_file" "router-user-data-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node
  source_raw {
    file_name   = "router-user-data.yaml"
    data        = templatefile(
                    "cloud-init/router/user-data.yaml",
                    {
                      host-ssh-key-ed25519 = tls_private_key.router-ssh-key
                    }
                  )
  }
}

resource "proxmox_virtual_environment_file" "router-network-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node
  source_raw {
    file_name   = "router-network-config.yaml"
    data        = templatefile(
                    "cloud-init/router/network-config.yaml",
                    {
                      host-ssh-key-ed25519 = tls_private_key.router-ssh-key
                      public_mac_addr      = var.router_mac_public
                      private_mac_addr     = var.router_mac_private
                    }
                  )
  }
}

resource "proxmox_virtual_environment_vm" "router" {
  name              = "homelab-router"
  description       = "Test Cloud-Init Router"
  tags              = ["cloud-init", "testing"]
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
    network_data_file_id  = proxmox_virtual_environment_file.router-network-data-cloud-config.id
  }
}

###################### Test Virtual Machine ##

resource "tls_private_key" "test-vm-ssh-key" {
  algorithm = "ED25519"
}

resource "proxmox_virtual_environment_file" "test-user-data-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node
  source_raw {
    file_name   = "testvm-user-data.yaml"
    data        = templatefile(
                    "cloud-init/test/user-data.yaml",
                    {
                      host-ssh-key-ed25519 = tls_private_key.test-vm-ssh-key.private_key_pem
                    }
                  )
  }
}

resource "proxmox_virtual_environment_vm" "test-vm" {
  name              = "homelab-router"
  description       = "Test Cloud-Init Router"
  tags              = ["cloud-init", "testing"]
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
    datastore_id        = "cloudinit"

    dns {
      servers             = [ "1.1.1.1", "4.4.4.4" ]
    }

    ip_config {
      ipv4 {
        address         = "192.168.128.10/16"
        gateway         = "192.168.128.1"
      }
    }

    user_data_file_id   = proxmox_virtual_environment_file.test-user-data-cloud-config.id
  }
}







