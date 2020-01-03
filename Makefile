.PHONY: help
help: ## Prints help (only for targets with comments)
	@grep -E '^[a-zA-Z._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up:
	vagrant up --no-provision

bootstrap: up ## Create necessary VMs and install necessary binaries
	vagrant provision

provision: bootstrap ## Create necessary VMs and provision the VMs and install necessary binaries for manual setup
	K8S_PLAYBOOK="manual-setup" vagrant provision

destroy.vm:
	-vagrant destroy --force

destroy: destroy.vm ## Destroy all the Vms
	rm -rf .vagrant

status: ## Prints the VMs status
	vagrant status
