# Handy summary after apply: which VMs exist, on which node/bridge.
output "lab_vms" {
  description = "Created lab VMs (key => id/name)"
  value = {
    for k, vm in proxmox_virtual_environment_vm.lab :
    k => {
      vm_id  = vm.vm_id
      name   = vm.name
      node   = vm.node_name
      bridge = var.lab_bridge
    }
  }
}

output "reminder" {
  description = "Post-apply reminder"
  value       = "VMs are on ${var.lab_bridge} (isolated). Verify containment per docs/lab-guide.md before trusting isolation."
}
