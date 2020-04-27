.PHONY: help
help: ## Prints help (only for targets with comments)
	@grep -E '^[a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up:
	vagrant up --no-provision

CLUSTER_NAME_PREFIX?=k8s

provision.cluster: up ## Create necessary VMs and provision the VMs with K8s cluster
	K8S_PLAYBOOK="kubernetes" vagrant provision

destroy.vm:
	-vagrant destroy --force

destroy: destroy.vm ## Destroy all the Vms
	rm -r ${VAGRANT_DOTFILE_PATH}
	rm -f ${HOME}/.kube/configs/${USER}-${CLUSTER_NAME_PREFIX}.conf

status: ## Prints the VMs status
	$(info Status for "${CLUSTER_NAME_PREFIX}" cluster)
	vagrant status
