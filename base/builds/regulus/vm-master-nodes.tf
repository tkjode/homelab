resource "proxmox_virtual_environment_vm" "masters" {
  count                   = 3
  name                    = join("-", ["master", count.index])
  description             = "Kubernetes Master Node"
  tags                    = ["regulus", "master", "kubernetes"]
  node_name               = var.proxmox_node
  stop_on_destroy         = true

  depends_on              = [ proxmox_virtual_environment_vm.regulus-gateway ]

  agent {
    enabled               = false
  }

  cpu {
    cores                 = 8
    type                  = "x86-64-v2-AES"
  }

  memory {
    dedicated             = 8192
    floating              = 8192
  }

  disk {
    datastore_id          = "SSD"
    file_id               = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                  = 10
    interface             = "scsi0"
  }

  network_device {
    bridge                = var.cluster_network_bridge
  }

  operating_system {
    type                  = "l26"
  }

  initialization {
    datastore_id          = "cloudinit"

    user_data_file_id     = proxmox_virtual_environment_file.master_user_data_cloud_config[count.index].id
    network_data_file_id  = proxmox_virtual_environment_file.master_network_data_cloud_config[count.index].id
  }
}

resource "proxmox_virtual_environment_file" "master_user_data_cloud_config" {
  count         = 3
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = join("-", ["regulus", "master", count.index, "user", "config.yaml"])
    data        = templatefile(
                    "cloud-init/k8s-master/master-user-data.yaml.tftpl",
                    {
                      hostname   = join("-", ["master", count.index] )
                    }
                  )
  }
}

resource "proxmox_virtual_environment_file" "master_network_data_cloud_config" {
  count         = 3
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = "proxmox"

  source_raw {
    file_name   = join("-", ["regulus", "master", count.index, "network", "config.yaml"])
    data        = templatefile(
                    "cloud-init/k8s-master/master-network-config.yaml.tftpl",
                    {
                      ip_assignment   = var.master_ip_offset + count.index
                      gw_net_cluster  = var.gw_net_cluster
                      nameservers     = var.nameservers
                    }
                  )
  }
}