# =============================================================================
# Lab VMs on the isolated bridge (vmbr1)
# =============================================================================
# Creates one VM per entry in var.lab_vms, each wired ONLY to the isolated lab
# bridge. Because vmbr1 has no uplink of its own, these machines can only reach
# the outside world through pfSense — exactly the containment the lab depends on.
#
#   >>> REVIEW before `terraform apply`. This creates real VMs on your node. <<<
#   Schema note: attribute names can drift between bpg/proxmox releases. Run
#   `terraform init && terraform validate` after pinning your provider version.
# =============================================================================

resource "proxmox_virtual_environment_vm" "lab" {
  for_each = var.lab_vms

  name      = each.value.name
  node_name = var.node_name
  vm_id     = each.value.vm_id
  tags      = ["lab", "isolated", "claude-upgrade"]
  on_boot   = false # lab machines are started deliberately, not on host boot

  # No qemu-guest-agent on stock attacker/target images — don't wait for it.
  agent {
    enabled = false
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  # The whole point: a single NIC on the isolated lab bridge.
  network_device {
    bridge = var.lab_bridge
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk_size
  }

  # Boot from the install ISO on first run.
  cdrom {
    file_id = each.value.iso_file_id
  }

  operating_system {
    type = "l26" # Linux 2.6+/modern kernel
  }

  # Keep a console available for the install walkthrough in docs/lab-guide.md.
  vga {
    type = "std"
  }
}
