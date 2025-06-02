resource "proxmox_virtual_environment_vm" "cloud-init-test" {
  name        = "cloud-init-test"
  description = "Stand Up A VM with a Static IP"
  tags        = [ "lab", "cloud-init", "ubuntu" ]
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
    size          = 10
    interface     = "scsi0"
  }

  network_device {
    bridge = "vmbr0"   # Go on the default home network
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.253"
        gateway = "10.0.0.1"
      }
      dns {
        servers = [ "4.4.4.4", "1.1.1.1" ]
      }

      user_account {
        username = "githublab"
        keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
        password = random_password.ubuntu_vm_password.result
      }


}


resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}