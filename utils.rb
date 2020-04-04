def machine_name(machine)
  prefix = ENV.fetch("CLUSTER_NAME_PREFIX", "k8s")
  "#{prefix}-#{machine[:name]}"
end

def machine_by_role(machines, role)
  result = machines.map do |machine|
    if machine[:role] == role
      machine_name(machine)
    end
  end
  result.compact
end

def configure_provision(index, machines, node, extra_vars={})
  if machines.count == (index+1)
    common_host_group = machines.map { |machine| machine_name(machine) }
    master_host_group = machine_by_role(machines, "master")
    node_host_group = machine_by_role(machines, "node")
    playbook = ENV.fetch("K8S_PLAYBOOK", "basic")

    node.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "cluster/playbook/#{playbook}.yaml"
      ansible.limit = "all"
      ansible.groups = {
        "common": common_host_group,
        "master": master_host_group.compact,
        "node": node_host_group.compact,
      }
      ansible.extra_vars = extra_vars
    end
  end
end
