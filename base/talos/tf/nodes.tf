
resource "proxmox_virtual_environment_vm" "masters" {
  count = 3
  node_name = "${var.cluster}-master-${count.index}"
  tags = [ "kubernetes", "master", "talos", "${var.cluster}" ]
  pool_id = proxmox_virtual_environment_pool.cluster-nodes-pool.id
  stop_on_destroy = true

  startup {
    order=5
    up_delay=15
    down_delay=15
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.nodesizing.master.vcpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.master.mem
    floating = var.nodesizing.master.mem
  }

  disk {
    datastore_id = "SSD"
    interface = "scsi0"
    size = 40
    ssd = "true"
  }

  disk {
    datastore_id = var.iso_datastore
    file_id = "local:iso/talos-metal-amd64-v1.9.1.iso"
    interface = "scsi1"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.16.1.${count.index+4}/24"
        gateway = "172.16.1.1"
      }
    }
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.vmbr1.id
  }
}

resource "proxmox_virtual_environment_vm" "workers" {
  count = var.worker_count
  node_name = "${var.cluster}-worker-${count.index}"
  tags = [ "kubernetes", "worker", "talos", "${var.cluster}" ]
  pool_id = proxmox_virtual_environment_pool.cluster-nodes-pool.id

  stop_on_destroy = true

  startup {
    order = 10
    up_delay = 5
    down_delay = 5
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.nodesizing.worker.vcpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.nodesizing.worker.mem
    floating = var.nodesizing.worker.mem
  }

  disk {
    datastore_id = "SSD"
    interface = "scsi0"
    size = 40
    ssd = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id = "local:iso/talos-metal-amd64-v1.9.1.iso"
    interface = "ide2"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.16.1.${count.index+8}/24"
        gateway = "172.16.1.1"
      }
    }
  }

  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.vmbr1.name
  }

}