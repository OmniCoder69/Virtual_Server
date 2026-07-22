# Proxmox API connection.
#
# Auth uses an API TOKEN, not your root password — create one in the Proxmox UI
# under: Datacenter -> Permissions -> API Tokens. Give it a role that can manage
# VMs on the node. Pass the values in via terraform.tfvars (git-ignored) or the
# PROXMOX_VE_* environment variables — never hard-code secrets here.
provider "proxmox" {
  endpoint  = var.proxmox_endpoint       # e.g. https://10.0.0.44:8006/
  api_token = var.proxmox_api_token      # e.g. root@pam!terraform=<uuid>
  insecure  = var.proxmox_insecure       # true for the default self-signed cert
}
