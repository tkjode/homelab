resource "proxmox_virtual_environment_vm" "bastion" {
  name                  = "bastion"
  description           = "Regulus Bastion Hacking Machine"
  tags                  = [ "regulus", "cloud-init", "ubuntu" ]
  node_name             = var.proxmox_node
  stop_on_destroy       = true
  vm_id                 = var.proxmox-vmid-offset + 2
  pool_id               = proxmox_virtual_environment_pool.cluster.pool_id
#  depends_on            = [ null_resource.wait-for-haproxy-response ]

  agent {
    enabled             = true
  }

  cpu {
    cores               = 4
    type                = "x86-64-v2-AES"
  }

  memory {
    dedicated           = 4096
    floating            = 4096
  }

  disk {
    datastore_id        = "SSD"
    file_id             = proxmox_virtual_environment_download_file.ubuntu-cloud-server-iso.id
    size                = 25
    interface           = "scsi0"
  }

  network_device {
    bridge              = proxmox_virtual_environment_network_linux_bridge.proxmox-cluster-bridge.name
  }

  serial_device {}

  operating_system {
    type                = "l26"
  }

  initialization {
    datastore_id        = "cloudinit"

    dns {
      servers             = [ cidrhost(join("/", [ var.gw-net-home.network, var.gw-net-cluster.mask ]), var.gw-net-cluster.cidr) ]
      domain              = join(".", [ var.cluster-name, var.cluster-domain ])
    }

    ip_config {
      ipv4 {
        address         = join("/", [ cidrhost(join("/", [var.gw-net-cluster.network, var.gw-net-cluster.mask]), var.bastion-ip-offset), var.gw-net-cluster.mask ])
        gateway         = cidrhost(join("/", [ var.gw-net-home.network, var.gw-net-cluster.mask ]), var.gw-net-cluster.cidr)
      }
    }

    user_data_file_id   = proxmox_virtual_environment_file.bastion-cloud-config.id
  }
}

resource "proxmox_virtual_environment_file" "bastion-cloud-config" {
  content_type  = "snippets"
  datastore_id  = "snippets"
  node_name     = var.proxmox_node

  source_raw {
    file_name   = "bastion-user-data.yaml"
    data        = templatefile(
                    "cloud-init/bastion/bastion-user-data.yaml.tftpl",
                    {
                      bastion-rsa     = tls_private_key.bastion-rsa.private_key_pem
                      bastion-ecdsa   = tls_private_key.bastion-ecdsa.private_key_pem
                    }
                  )
  }
}

resource "tls_private_key" "bastion-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "bastion-ecdsa" {
  algorithm = "ECDSA"
}