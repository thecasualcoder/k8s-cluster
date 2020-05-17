# frozen_string_literal: true
require 'json'

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

def configure_provision(index, machines, preference, node, extra_vars = {})
  addons = preference.fetch(:addons, {})
  external_dns = addons.fetch(:external_dns, {})
  cert_manager = addons.fetch(:cert_manager, {})

  default_extra_vars = {
    "network_interface": 'enp0s8',
    "provider": 'virtualbox',
    "addons": {
      "ingress": {
        "enabled": addons.fetch(:ingress, false),
      },
      "csi": {
        "enabled": addons.fetch(:cloud_storage_interface, false),
        "upgrade": true
      },
      "ccm": {
        "enabled": addons.fetch(:cloud_control_manager, false),
      },
      "cert_manager": {
        "enabled": cert_manager.fetch(:enabled, false),
        "acme_email_address": cert_manager.fetch(:acme_email_address, 'example@example.test'),
        "environment": cert_manager.fetch(:environment, 'dev'),
      },
      "external_dns": {
        "enabled": external_dns.fetch(:enabled, false),
        "domain_filter": external_dns.fetch(:domain_filter, 'example.test'),
        "source": external_dns.fetch(:source, 'ingress'),
      },
      "ebs": {
        "enabled": addons.fetch(:open_elastic_block_storage, true),
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
      if ENV.fetch('DEBUG', 'false') == 'true'
        puts '## Configurations'
        puts
        puts JSON.pretty_generate(ansible.extra_vars)
      end
    end
  end
end
