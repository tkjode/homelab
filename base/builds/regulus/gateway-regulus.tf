resource "proxmox_virtual_environment_vm" "regulus-gateway" {
  name        = var.gw_hostname
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
    bridge = var.home_network_bridge
    mac_address = var.gw_net_home.mac
  }

  network_device {
    bridge = var.cluster_network_bridge
    mac_address  = var.gw_net_cluster.mac
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

  source_raw {
    file_name   = "regulus-gateway-user-data.yaml"
    data        = templatefile(
                    "cloud-init/gateway/user-data.yaml.tftpl",
                    { gw_hostname = var.gw_hostname }
                  )
  }
}

resource "proxmox_virtual_environment_file" "gateway_network_data_cloud_config" {
  content_type    = "snippets"
  datastore_id    = "snippets"
  node_name       = var.proxmox_node

  source_raw {
    file_name = "regulus-gateway-network-config.yaml"
    data = templatefile(
              "cloud-init/gateway/network-config.yaml.tftpl", 
              { 
                gw_net_home = var.gw_net_home, 
                gw_net_cluster = var.gw_net_cluster, 
                nameservers = var.nameservers 
              }
            )
    
  }
}
