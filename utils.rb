# frozen_string_literal: true

def symbolize_hash(hash)
  JSON.parse(JSON[hash], symbolize_names: true)
end

def pick(hash, keys_to_extract)
  hash.select do |key, _|
    keys_to_extract.include? key
  end
end

def merge(dest, src)
  dest.merge(pick(symbolize_hash(src), dest.keys))
end

def machine_by_role(machines, role)
  result = machines.map do |machine|
    machine[:name] if machine[:role] == role
  end
  result.compact
end

def configure_provision(index, machines, node, extra_vars = {})
  default_extra_vars = {
    "network_interface": 'enp0s8',
    "provider": 'virtualbox',
    "addons": {
      "ingress": {
        "enabled": ENV.fetch('ADDONS_INGRESS_ENABLED', 'false')
      },
      "csi": {
        "enabled": ENV.fetch('ADDONS_CSI_ENABLED', 'false'),
        "upgrade": true
      },
      "ccm": {
        "enabled": ENV.fetch('ADDONS_CCM_ENABLED', 'false')
      },
      "cert_manager": {
        "enabled": ENV.fetch('ADDONS_CERT_MANAGER_ENABLED', 'false'),
        "acme_email_address": ENV.fetch('ADDONS_CERT_MANAGER_ACME_EMAIL_ADDRESS', 'example@example.test'),
        "environment": ENV.fetch('ADDONS_CERT_MANAGER_ENVIRONMENT', 'dev')
      },
      "external_dns": {
        "enabled": ENV.fetch('ADDONS_EXTERNAL_DNS_ENABLED', 'false'),
        "domain_filter": ENV.fetch('ADDONS_EXTERNAL_DNS_DOMAIN_FILTER', 'example.test'),
        "source": ENV.fetch('ADDONS_EXTERNAL_DNS_SOURCE', 'service')
      },
      "ebs": {
        "enabled": ENV.fetch('ADDONS_EBS_ENABLED', 'true')
      }
    }
  }
  if machines.count == (index + 1)
    common_host_group = machines.map { |machine| machine[:name] }
    master_host_group = machine_by_role(machines, 'master')
    node_host_group = machine_by_role(machines, 'node')
    playbook = ENV.fetch('K8S_PLAYBOOK', 'basic')

    node.vm.provision 'ansible' do |ansible|
      ansible.compatibility_mode = '2.0'
      ansible.playbook = "cluster/playbook/#{playbook}.yaml"
      ansible.limit = 'all'
      ansible.groups = {
        "common": common_host_group,
        "master": master_host_group.compact,
        "node": node_host_group.compact
      }
      ansible.extra_vars = default_extra_vars.merge(extra_vars)
    end
  end
end
