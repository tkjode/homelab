resource "proxmox_virtual_environment_vm" "workers" {
  count                     = var.worker-count
  name                      = join("-", ["worker", count.index])
  description               = "Kubernetes Worker Node"
  tags                      = [var.cluster-name, "worker", "kubernetes"]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true

  depends_on                = [ proxmox_virtual_environment_vm.regulus-gateway ]

  agent {
    enabled                 = false
  }

  cpu {
    cores                   = 16
    type                    = "x86-64-v2-AES"
  }

  memory {
    dedicated               = 16384
    floating                = 16384
  }

  disk {
    datastore_id            = "SSD"
    file_id                 = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                    = 25
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
      domain                = join(".", [var.cluster-name, var.cluster-domain])
    }
    ip_config {
      ipv4 {
        address             = join("/", [ cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.worker-ip-offset + count.index), var.gw-net-cluster.mask ])
        gateway             = cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr)
      }
    }

    user_data_file_id       = proxmox_virtual_environment_file.worker-user-data-cloud-config[count.index].id

  }
}

resource "proxmox_virtual_environment_file" "worker-user-data-cloud-config" {
  count         = var.worker-count
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = join("-", ["regulus", "worker", count.index, "user", "config.yaml"])
    data        = templatefile(
                    "cloud-init/k8s-worker/worker-user-data.yaml.tftpl",
                    {
                      hostname                = join("-", ["worker", count.index] ),
                      control-plane-endpoint  = cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.gw-net-cluster.cidr),
                      cluster-join-token      = var.cluster-join-token,
                      node-select             = count.index
                      cluster-name            = var.cluster-name
                      pod-network             = var.pod-network
                      service-network         = var.service-network
                      kubernetes-ca-crt       = tls_locally_signed_cert.kubernetes-ca.cert_pem
                    }
                  )
  }
}
