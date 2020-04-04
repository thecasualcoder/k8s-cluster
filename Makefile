.PHONY: help
help: ## Prints help (only for targets with comments)
	@grep -E '^[a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up:
	vagrant up --no-provision

provision.basic: up ## Create necessary VMs and install necessary binaries
	K8S_PLAYBOOK="basic" vagrant provision

provision.manual: up ## Create necessary VMs and provision the VMs and install necessary binaries for manual setup
	K8S_PLAYBOOK="manual-setup" vagrant provision

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

reset: ## Reset the kubernetes cluster
	ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory playbook/kubernetes-reset.yaml

switch.k8s: ## Switch to k8s cluster
	sed -i'' -e 's/CLUSTER_NAME_PREFIX="systems"/CLUSTER_NAME_PREFIX="k8s"/g' .envrc
	direnv allow

switch.systems: ## Switch to systems cluster
	sed -i'' -e 's/CLUSTER_NAME_PREFIX="k8s"/CLUSTER_NAME_PREFIX="systems"/g' .envrc
	direnv allow