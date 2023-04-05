terraform {
  required_version = ">= 1.1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.5"
    }
  }
}

provider "proxmox" {
  pm_api_url   = var.pm_api_url
  pm_user      = var.pm_user
  pm_password  = var.pm_password
  pm_tls_insecure  = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "small" {
  count	      = "${length(var.small)}"
  name        = "${var.small[count.index]}"
  target_node = var.target_node	
  clone       = "${var.specs.templateName}"
  full_clone  = true
  os_type     = "l26"
  cores       = "${var.specs.small-cpu}"
  sockets     = "${var.specs.small-sockets}"
  memory      = "${var.specs.small-memory}"
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  network {
    model   = "virtio"
    bridge  = "vmbr0"
  }
  disk {
    type = "scsi"
    storage = "nvme"
    size = "${var.specs.small-disk}"
  }
}

resource "proxmox_vm_qemu" "medium" {
  # agent = 0
  count       = "${length(var.medium)}"
  name        = "${var.medium[count.index]}"
  target_node = var.target_node
  clone       = "${var.specs.templateName}"
  full_clone  = true
  os_type     = "l26"
  cores       = "${var.specs.medium-cpu}"
  sockets     = "${var.specs.medium-sockets}"
  memory      = "${var.specs.medium-memory}"
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  network {
    model   = "virtio"
    bridge  = "vmbr0"
  }
  disk {
    type = "scsi"
    storage = "nvme"
    size = "${var.specs.medium-disk}"
  }
}













