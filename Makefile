# =============================================================================
# Virtual_Server homelab — build orchestration
# =============================================================================
# A thin wrapper that ties the reproducible stages together. Nothing here does
# anything destructive by default: the bridge and Terraform targets are DRY-RUN
# / PLAN only. The real-change targets end in `-apply` and are called out below.
#
#   >>> REVIEW every command before running it against real hardware. <<<
#
# Quick start:
#   make help          # list all targets
#   make lint          # static-check the scripts / IaC with whatever is installed
#   make bridge        # DRY-RUN: show the vmbr1 plan (no changes)
#   make bridge-apply  # REAL: create vmbr1 on this Proxmox host (root)
#   make wg-client NAME=laptop
#   make tf-plan       # Terraform plan for the lab VMs
# =============================================================================

SHELL       := /bin/bash
SCRIPTS_DIR := scripts
TF_DIR      := infra/terraform
ANSIBLE_DIR := infra/ansible
NAME        ?= client            # override: make wg-client NAME=laptop

.DEFAULT_GOAL := help

.PHONY: help preflight lint bridge bridge-apply wg-client \
        tf-init tf-plan tf-apply ansible-check ansible-apply

help: ## Show this help
	@echo "Virtual_Server homelab — make targets:"
	@echo
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "  DRY-RUN by default. Targets ending in -apply make real changes."

preflight: ## Check which optional tools are installed
	@for t in bash shellcheck terraform ansible-playbook wg; do \
	  if command -v $$t >/dev/null 2>&1; then printf "  [+] %-16s %s\n" "$$t" "found"; \
	  else printf "  [ ] %-16s %s\n" "$$t" "missing (optional)"; fi; \
	done

lint: ## Static-check scripts + IaC (uses whatever tools are installed)
	@echo "== bash syntax =="; for s in $(SCRIPTS_DIR)/*.sh; do bash -n "$$s" && echo "  ok: $$s"; done
	@echo "== shellcheck =="; command -v shellcheck >/dev/null 2>&1 \
	  && shellcheck $(SCRIPTS_DIR)/*.sh || echo "  (shellcheck not installed — skipped)"
	@echo "== terraform =="; command -v terraform >/dev/null 2>&1 \
	  && (cd $(TF_DIR) && terraform fmt -check -recursive && terraform validate) \
	  || echo "  (terraform not installed — skipped)"
	@echo "== ansible =="; command -v ansible-playbook >/dev/null 2>&1 \
	  && ansible-playbook --syntax-check $(ANSIBLE_DIR)/playbook.yml -i $(ANSIBLE_DIR)/inventory.example.ini \
	  || echo "  (ansible not installed — skipped)"

bridge: ## DRY-RUN: show the isolated vmbr1 bridge plan (no changes)
	@$(SCRIPTS_DIR)/create-vmbr1.sh

bridge-apply: ## REAL: create the isolated vmbr1 bridge (run on the Proxmox host as root)
	@$(SCRIPTS_DIR)/create-vmbr1.sh --apply

wg-client: ## Generate a WireGuard client profile (make wg-client NAME=laptop)
	@$(SCRIPTS_DIR)/wg-client-gen.sh --name "$(NAME)"

tf-init: ## Terraform: init the lab-VM stack
	@cd $(TF_DIR) && terraform init

tf-plan: ## Terraform: plan the lab VMs (no changes)
	@cd $(TF_DIR) && terraform plan

tf-apply: ## REAL: Terraform apply — create the lab VMs on Proxmox
	@cd $(TF_DIR) && terraform apply

ansible-check: ## Ansible: dry-run (--check) the target baseline playbook
	@cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.ini playbook.yml --check

ansible-apply: ## REAL: Ansible apply — baseline the lab targets
	@cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.ini playbook.yml
