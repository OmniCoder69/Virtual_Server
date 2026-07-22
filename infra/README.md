<sub>[← Back to README](../README.md)</sub>

# Infrastructure-as-Code

This turns the manual lab build into something reproducible: **Terraform** stands
up the lab VMs on the isolated bridge, and **Ansible** baselines them. Both are
starting points meant to be reviewed and adapted — not run blind.

> [!WARNING]
> **REVIEW everything here before running it against real hardware.** These tools
> create and modify real VMs. Nothing runs automatically; every step is an explicit
> command. The Terraform provider schema can also drift between releases — always
> `terraform init && terraform validate` after pinning your provider version.

---

## Layout

```text
infra/
├── terraform/            # create the lab VMs on vmbr1 (bpg/proxmox provider)
│   ├── versions.tf       #   provider + version pins
│   ├── providers.tf      #   Proxmox API connection (token auth)
│   ├── variables.tf      #   node, bridge, datastore, and the lab_vms map
│   ├── main.tf           #   one VM per lab_vms entry, all on the isolated bridge
│   ├── outputs.tf
│   └── terraform.tfvars.example   # copy -> terraform.tfvars (git-ignored)
└── ansible/              # baseline the lab machines
    ├── ansible.cfg
    ├── inventory.example.ini      # copy -> inventory.ini (git-ignored)
    ├── playbook.yml               # installs tooling + ASSERTS isolation
    └── group_vars/all.example.yml
```

## Prerequisites

1. Proxmox host reachable, with the **isolated bridge `vmbr1`** already created
   (see [`scripts/create-vmbr1.sh`](../scripts/create-vmbr1.sh)).
2. A Proxmox **API token** (Datacenter → Permissions → API Tokens).
3. The attacker/target **ISOs uploaded** to Proxmox storage
   (see [Proxmox: Upload ISO Images](../proxmox/proxmox_setup.md#5-upload-iso-images)).
4. `terraform` and `ansible` installed on your workstation.

## Terraform — create the VMs

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # then fill in your token + values
terraform init
terraform validate
terraform plan            # review — this is the safe step
terraform apply           # creates the VMs (real change)
```

Every VM is attached to **`vmbr1` only**. Because that bridge has no uplink, the
VMs are contained by construction — their sole path off-net is through pfSense.

## Ansible — baseline the machines

Run this **from a host on the isolated network** (the lab is walled off, so an
external controller can't reach it):

```bash
cd infra/ansible
cp inventory.example.ini inventory.ini         # set the real 10.10.10.x IPs
ansible-playbook -i inventory.ini playbook.yml --check   # dry-run
ansible-playbook -i inventory.ini playbook.yml           # apply
```

The attacker play installs baseline tooling **and asserts containment** — it
pings `8.8.8.8` (should work) and `10.0.0.1` (should fail), and **fails the run**
if the home LAN is reachable. That way a broken isolation boundary is caught
before you start attacking anything.

## Secrets

`terraform.tfvars`, `inventory.ini`, `*.tfstate`, and real `group_vars/*.yml` are
all git-ignored. Commit only the `*.example` files. See [../SECURITY.md](../SECURITY.md).
