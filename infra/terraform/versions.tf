# Provider + version pinning for the lab-VM stack.
# The bpg/proxmox provider talks to the Proxmox VE API directly (no SSH needed
# for most operations). Docs: https://registry.terraform.io/providers/bpg/proxmox
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}
