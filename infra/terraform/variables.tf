# ---- Proxmox connection -----------------------------------------------------
variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint, e.g. https://10.0.0.44:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token, e.g. root@pam!terraform=<uuid>"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification (true for the default self-signed cert)"
  type        = bool
  default     = true
}

# ---- Placement --------------------------------------------------------------
variable "node_name" {
  description = "Proxmox node the lab runs on"
  type        = string
  default     = "uno"
}

variable "lab_bridge" {
  description = "Isolated lab bridge the VMs attach to (created by scripts/create-vmbr1.sh)"
  type        = string
  default     = "vmbr1"
}

variable "datastore_id" {
  description = "Datastore for VM disks"
  type        = string
  default     = "local-lvm"
}

# ---- The lab VMs ------------------------------------------------------------
# A map of VMs to create, all attached to the isolated lab bridge. Add/remove
# entries here to grow the range. iso_file_id points at an ISO already uploaded
# to Proxmox (see proxmox/proxmox_setup.md "Upload ISO Images").
variable "lab_vms" {
  description = "Lab VMs to create on the isolated bridge"
  type = map(object({
    name        = string
    vm_id       = number
    cores       = number
    memory      = number # MiB
    disk_size   = number # GiB
    iso_file_id = string # e.g. local:iso/kali-linux-2024.1-installer-amd64.iso
  }))
  # Defaults describe the starter lab: one attacker, one vulnerable target.
  default = {
    kali = {
      name        = "kali-attacker"
      vm_id       = 201
      cores       = 2
      memory      = 4096
      disk_size   = 30
      iso_file_id = "local:iso/kali-linux-installer-amd64.iso"
    }
    target = {
      name        = "metasploitable-target"
      vm_id       = 202
      cores       = 1
      memory      = 2048
      disk_size   = 16
      iso_file_id = "local:iso/metasploitable.iso"
    }
  }
}
