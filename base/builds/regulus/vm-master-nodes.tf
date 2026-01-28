resource "proxmox_virtual_environment_vm" "masters" {
  count                     = 3
  name                      = join("-", ["master", count.index])
  description               = "Kubernetes Master Node"
  tags                      = [var.cluster-name, "master", "kubernetes"]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true
  vm_id                     = var.proxmox-vmid-offset + var.master-ip-offset + count.index
#  depends_on                = [ null_resource.wait-for-haproxy-response ]
  pool_id                   = proxmox_virtual_environment_pool.cluster.pool_id

  agent {
    enabled                 = true
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

locals {
  argocd-application-bootstrap = file("argocd/Application.bootstrap.yaml")
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
                      kubernetes-version      = var.kubernetes-version
                      kubernetes-ca-crt       = tls_locally_signed_cert.kubernetes-ca.cert_pem
                      kubernetes-ca-key       =         tls_private_key.kubernetes-ca.private_key_pem
                      front-proxy-ca-crt      = tls_locally_signed_cert.front-proxy-ca.cert_pem
                      front-proxy-ca-key      =         tls_private_key.front-proxy-ca.private_key_pem
                      etcd-ca-crt             = tls_locally_signed_cert.etcd-ca.cert_pem
                      etcd-ca-key             =         tls_private_key.etcd-ca.private_key_pem
                      sa-pub                  = tls_private_key.sa-key.public_key_pem
                      sa-key                  = tls_private_key.sa-key.private_key_pem
                      argocd-ssh-private-key  = var.argocd-ssh-private-key
                      repository-url          = var.repository-url
                      bootstrap-application   = local.argocd-application-bootstrap
                      labs-ca-crt             = tls_self_signed_cert.labs-ca.cert_pem
                      labs-ca-key             =      tls_private_key.labs-ca.private_key_pem
                    }
                  )
  }
}

resource "proxmox_virtual_environment_firewall_options" "master-fw" {
  count       = 3
  node_name   = var.proxmox_node
  vm_id       = proxmox_virtual_environment_vm.masters[count.index].vm_id

  dhcp          = false
  enabled       = false
  ipfilter      = false
  log_level_in  = "nolog"
  log_level_out = "nolog"
  macfilter     = false
  ndp           = true
  input_policy  = "ACCEPT"
  output_policy = "ACCEPT"
  radv          = false
}

resource "null_resource" "wait-for-kubernetes-api" {
  provisioner "local-exec" {
    command = <<EOT
    for i in $(seq 1 30); do
      OUTPUT=$(curl -k https://${cidrhost(join("/", [ var.gw-net-home.network, var.gw-net-home.mask ]), var.gw-net-home.cidr)}:6443/livez)
      EC=$?
      if [ $OUTPUT != "ok" ]; then
        echo "Waiting for Kubernetes API to Respond.  Attempt $i of 30"
      else
        echo "HAProxy responding.  It's Go Time!"
        break
      fi
    done
    EOT
  }

  triggers = {
    master_instances = proxmox_virtual_environment_vm.masters
  }

}