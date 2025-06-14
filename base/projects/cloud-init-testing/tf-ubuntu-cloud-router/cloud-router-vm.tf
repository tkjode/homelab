resource "proxmox_virtual_environment_vm" "cloud-init-test" {
  name        = "cloud-router-test"
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
    bridge = "vmbr0"   # Go on the default home network
    mac_address = "BC:24:11:D0:6F:75"
  }

  network_device {
    bridge = "vmbr1"
    mac_address  = "BC:24:11:EE:6F:75"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "cloudinit"

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    network_data_file_id = proxmox_virtual_environment_file.network_data_cloud_config.id
  }

}

resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  node_name   = var.proxmox_node
  name        = "vmbr1"
  comment     = "Private Network Bridge 1"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_file {
    path = "test-router-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "network_data_cloud_config" {
  content_type    = "snippets"
  datastore_id    = "snippets"
  node_name       = var.proxmox_node

  source_file {
    path = "test-router-network-config.yaml"
  }
}
resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}