resource "proxmox_virtual_environment_vm" "regulus-gateway" {
  name                      = var.gw-hostname
  description               = "Cluster Gateway and HAProxy Ingress"
  tags                      = [ var.cluster-name, "cloud-init", "ubuntu" ]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true
  vm_id                      = var.proxmox-vmid-offset + 1

  agent {
    enabled                 = true
  }

  cpu {
    cores                   = 2
    type                    = "x86-64-v2-AES"
  }

  memory {
    dedicated               = 1024
    floating                = 1024
  }

  disk {
    datastore_id            = "SSD"
    file_id                 = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                    = 10
    interface               = "scsi0"
  }

  serial_device { }

  network_device {
    bridge                  = var.home-network-bridge
    mac_address             = var.gw-net-home.mac
  }

  network_device {
    bridge                  = proxmox_virtual_environment_network_linux_bridge.proxmox-cluster-bridge.name
    mac_address             = var.gw-net-cluster.mac
  }

  operating_system {
    type                    = "l26"
  }

  initialization {
    datastore_id            = "cloudinit"

    user_data_file_id       = proxmox_virtual_environment_file.gateway-user-data-cloud-config.id
    network_data_file_id    = proxmox_virtual_environment_file.gateway-network-data-cloud-config.id
  }

}


resource "proxmox_virtual_environment_file" "gateway-user-data-cloud-config" {
  content_type              = "snippets"
  datastore_id              = "snippets"
  node_name                 = var.proxmox_node

  source_raw {
    file_name               = "regulus-gateway-user-data.yaml"
    data                    = templatefile(
                                "cloud-init/gateway/gw-user-data.yaml.tftpl",
                                {
                                  gw-net-cluster      = var.gw-net-cluster
                                  gw-hostname         = var.gw-hostname
                                  master-ip-offset    = var.master-ip-offset
                                }
                              )
  }
}

resource "proxmox_virtual_environment_file" "gateway-network-data-cloud-config" {
  content_type              = "snippets"
  datastore_id              = "snippets"
  node_name                 = var.proxmox_node

  source_raw {
    file_name = "regulus-gateway-network-config.yaml"
    data = templatefile(
              "cloud-init/gateway/gw-network-config.yaml.tftpl",
              {
                gw-net-home       = var.gw-net-home
                gw-net-cluster    = var.gw-net-cluster
                nameservers       = var.nameservers
              }
            )

  }
}
