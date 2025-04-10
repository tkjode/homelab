
resource "proxmox_virtual_environment_vm" "masters" {
  # depends_on       = [ proxmox_virtual_environment_vm.gw-opnsense ]
  count           = 3
  name            = "${ var.cluster }-master-${ count.index }"
  node_name       = var.target_proxmox_node_name
  tags            = [ "kubernetes", "master", "talos", "${ var.cluster }" ]
  # pool_id         = proxmox_virtual_environment_pool.cluster-nodes-pool.id
  stop_on_destroy = true

  startup {
    order       = 5
    up_delay    = 15
    down_delay  = 15
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.nodesizing.master.vcpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.master.mem
    floating  = var.nodesizing.master.mem
  }

  disk {
    file_format   = "raw"
    datastore_id  = "SSD"
    interface     = "scsi0"
    size          = 40
    ssd           = "true"
  }

  cdrom {
    enabled       = true
    file_id       = "${ var.iso_datastore }:iso/talos-metal-amd64-v1.9.1.iso"
  }

  initialization {
    datastore_id  = "cloudinit"
    ip_config {
      ipv4 {
        address = "172.16.1.${ count.index+4 }/24"
        gateway = "172.16.1.1"
      }
    }
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.cluster-private-bridge.name
  }
}

resource "proxmox_virtual_environment_vm" "workers" {
  # depends_on      = [ proxmox_virtual_environment_vm.gw-opnsense ]
  count           = var.worker_count
  name            = "${ var.cluster }-worker-${ count.index }"
  node_name       = var.target_proxmox_node_name
  tags            = [ "kubernetes", "worker", "talos", "${ var.cluster }" ]
  # pool_id         = proxmox_virtual_environment_pool.cluster-nodes-pool.id
  stop_on_destroy = true

  startup {
    order       = 10
    up_delay    = 5
    down_delay  = 5
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.nodesizing.worker.vcpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.worker.mem
    floating  = var.nodesizing.worker.mem
  }

  disk {
    file_format   = "raw"
    datastore_id  = "SSD"
    interface     = "scsi0"
    size          = 40
    ssd           = true
  }

  cdrom {
    enabled       = true
    file_id       = "${ var.iso_datastore }:iso/talos-metal-amd64-v1.9.1.iso"
  }

  initialization {
    datastore_id  = "cloudinit"
    ip_config {
      ipv4 {
        address = "172.16.1.${ count.index+8 }/24"
        gateway = "172.16.1.1"
      }
    }
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.cluster-private-bridge.name
  }

}