resource "proxmox_virtual_environment_vm" "regulus-gateway" {
  name        = var.gw_hostname
  description = "Regulus Cluster Gateway and NGINX Ingress"
  tags        = [ "regulus", "cloud-init", "ubuntu" ]
  node_name   = var.proxmox_node
  stop_on_destroy = true

  agent {
    enabled = false
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
    bridge = "vmbr0"
    mac_address = var.gw_net_home.mac
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.proxmox-cluster-bridge.name
    mac_address  = var.gw_net_cluster.mac
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "cloudinit"

    user_data_file_id = proxmox_virtual_environment_file.gateway-user-data-cloud-config.id
    network_data_file_id = proxmox_virtual_environment_file.gateway-network-data-cloud-config.id
  }

}


resource "proxmox_virtual_environment_file" "gateway-user-data-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = "regulus-gateway-user-data.yaml"
    data        = templatefile(
                    "cloud-init/gateway/gw-user-data.yaml.tftpl",
                    {
                      gw_net_cluster    = var.gw_net_cluster
                      gw_hostname       = var.gw_hostname
                      master_ip_offset  = var.master_ip_offset
                      k8s-api-pem       = tls_self_signed_cert.k8s-api-certificate.cert_pem
                      ingress-pem       = tls_self_signed_cert.ingress-certificate.cert_pem
                      k8s-api-private-key = tls_private_key.k8s-api-private-key.private_key_pem
                      ingress-private-key = tls_private_key.ingress-private-key.private_key_pem
                    }
                  )
  }
}

resource "proxmox_virtual_environment_file" "gateway-network-data-cloud-config" {
  content_type    = "snippets"
  datastore_id    = "snippets"
  node_name       = var.proxmox_node

  source_raw {
    file_name = "regulus-gateway-network-config.yaml"
    data = templatefile(
              "cloud-init/gateway/gw-network-config.yaml.tftpl",
              {
                gw_net_home       = var.gw_net_home
                gw_net_cluster    = var.gw_net_cluster
                nameservers       = var.nameservers
              }
            )

  }
}
