resource "proxmox_virtual_environment_vm" "regulus-gateway" {
  name                      = var.gw-hostname
  description               = "Cluster Gateway and HAProxy Ingress"
  tags                      = [ var.cluster-name, "cloud-init", "ubuntu" ]
  node_name                 = var.proxmox_node
  stop_on_destroy           = true
  vm_id                     = var.proxmox-vmid-offset + 1
  pool_id                   = proxmox_virtual_environment_pool.cluster.pool_id

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
                                  gw-net-cluster          = var.gw-net-cluster
                                  gw-hostname             = var.gw-hostname
                                  master-ip-offset        = var.master-ip-offset
                                  haproxy_tls_cert        = tls_locally_signed_cert.cert-apps-phalnet-com.cert_pem
                                  haproxy_key             = tls_private_key.apps-proxy-master.private_key_pem
                                  kube_ingress_ca         = tls_locally_signed_cert.front-proxy-ca.cert_pem
                                    gateway-rsa           = tls_private_key.gateway-rsa.private_key_pem
                                    gateway-ecdsa         = tls_private_key.gateway-ecdsa.private_key_pem
                                  certbot_aws_access_key  = var.certbot_aws_access_key
                                  certbot_aws_secret_key  = var.certbot_aws_secret_key
                                  certbot_contact_email   = var.certbot_contact_email
                                  cluster_domain          = var.cluster-domain
                                  cluster_name            = var.cluster-name
                                  ingress_prefix          = var.default-ingress-prefix
                                  letsencrypt_storage     = var.letsencrypt-storage
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

resource "null_resource" "wait-for-haproxy-response" {
  provisioner "local-exec" {
    command = <<EOT
    for i in $(seq 1 30); do
      OUTPUT=$(curl http://${cidrhost(join("/", [ var.gw-net-home.network, var.gw-net-home.mask ]), var.gw-net-home.cidr)}/stats)
      EC=$?
      if [ $EC != "0" ]; then
        echo "Waiting for HAProxy to Start.  Attempt $i of 30"
      else
        echo "HAProxy responding.  It's Go Time!"
        break
      fi
    done
    EOT
  }

  triggers = {
    instance_id = proxmox_virtual_environment_vm.bastion.id
  }

}

resource "tls_private_key" "gateway-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "gateway-ecdsa" {
  algorithm = "ECDSA"
}

resource "proxmox_virtual_environment_firewall_options" "gateway-fw" {
  node_name   = var.proxmox_node
  vm_id       = proxmox_virtual_environment_vm.regulus-gateway.vm_id

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