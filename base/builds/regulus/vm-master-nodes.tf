resource "proxmox_virtual_environment_vm" "masters" {
  count                     = 3
  name                      = join("-", ["master", count.index])
  description               = "Kubernetes Master Node"
  tags                      = [var.cluster-name, "master", "kubernetes"]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true

  depends_on                = [ proxmox_virtual_environment_vm.regulus-gateway ]

  agent {
    enabled                 = false
  }

  cpu {
    cores                   = 8
    type                    = "x86-64-v2-AES"
  }

  memory {
    dedicated               = 8192
    floating                = 8192
  }

  disk {
    datastore_id            = "SSD"
    file_id                 = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                    = 10
    interface               = "scsi0"
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
      domain                = join(".", [ var.cluster-name, var.cluster-domain ])
    }
    ip_config {
      ipv4 {
        address             = join("/", [ cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.master-ip-offset + count.index), var.gw-net-cluster.mask ])
        gateway             = cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr)
      }
    }

    user_data_file_id       = proxmox_virtual_environment_file.master-user-data-cloud-config[count.index].id

  }
}

resource "proxmox_virtual_environment_file" "master-user-data-cloud-config" {
  count         = 3
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = join("-", ["regulus", "master", count.index, "user", "config.yaml"])
    data        = templatefile(
                    "cloud-init/k8s-master/master-user-data.yaml.tftpl",
                    {
                      hostname                = join("-", ["master", count.index] ),
                      control-plane-endpoint  = cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr),
                      cluster-join-token      = var.cluster-join-token,
                      node-select             = count.index
                      cluster-name            = var.cluster-name
                      pod-network             = var.pod-network
                      service-network         = var.service-network
                      kubernetes-ca-crt       = tls_locally_signed_cert.kubernetes-ca.cert_pem
                      kubernetes-ca-key       =      tls_private_key.kubernetes-ca.private_key_pem
                      kubernetes-ca-sha256    =      tls_private_key.kubernetes-ca.public_key_fingerprint_sha256
                      front-proxy-ca-crt      = tls_locally_signed_cert.front-proxy-ca.cert_pem
                      front-proxy-ca-key      =      tls_private_key.front-proxy-ca.private_key_pem
                      etcd-ca-crt             = tls_locally_signed_cert.etcd-ca.cert_pem
                      etcd-ca-key             =      tls_private_key.etcd-ca.private_key_pem
                      sa-pub                  = tls_private_key.sa-key.public_key_pem
                      sa-key                  = tls_private_key.sa-key.private_key_pem

                    }
                  )
  }
}
