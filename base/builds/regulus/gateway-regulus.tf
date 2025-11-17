resource "proxmox_virtual_environment_vm" "regulus-gateway" {
  name        = "regulus-gateway"
  description = "Regulus Cluster Gateway and NGINX Ingress"
  tags        = [ "regulus", "cloud-init", "ubuntu" ]
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
    mac_address = "bc:24:11:d0:6e:75"
  }

  network_device {
    bridge = "vmbr10"
    mac_address  = "bc:24:11:ee:6e:75"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "cloudinit"

    user_data_file_id = proxmox_virtual_environment_file.gateway_user_data_cloud_config.id
    network_data_file_id = proxmox_virtual_environment_file.gateway_network_data_cloud_config.id
  }

}


resource "proxmox_virtual_environment_file" "gateway_user_data_cloud_config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_file {
    file_name = "regulus-gateway-user-data.yaml"
    path = "cloud-init/gateway/user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "gateway_network_data_cloud_config" {
  content_type    = "snippets"
  datastore_id    = "snippets"
  node_name       = var.proxmox_node

  source_file {
    file_name = "regulus-gateway-network-config.yaml"
    path = "cloud-init/gateway/network-config.yaml"
  }
}
