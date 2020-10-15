# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'psych'
require_relative('utils')
require_relative('defaults')

def create_vms_on_virtualbox(machines, config, preference)
  machines.each_with_index do |machine, index|
    config.vm.define machine[:name] do |node|
      node.vm.provider 'virtualbox' do |provider, override|
        provider.cpus = machine[:cpus]
        provider.memory = machine[:memory]
        override.vm.box = machine[:box]
        override.vm.hostname = machine[:name]
        override.vm.network 'private_network', ip: machine[:virtualbox_private_ip]
        override.vm.synced_folder '.', '/vagrant', disabled: true
        configure_provision(index, machines, preference, override, {
                              "network_interface": 'enp0s8',
                              "provider": 'virtualbox',
                              "use_private_ip_for_external_access": true
                            })
      end
    end
  end
end

def create_vms_on_digital_ocean(machines, config, preference)
  cluster_name_prefix = ENV.fetch('CLUSTER_NAME_PREFIX', 'k8s')

  machines.each_with_index do |machine, index|
    config.vm.define machine[:name] do |node|
      node.vm.provider :digital_ocean do |provider, override|
        provider.image = machine[:image]
        provider.region = machine[:region]
        provider.size = machine[:size]

        provider.ssh_key_name = ENV['DIGITAL_OCEAN_SSH_KEY_NAME']
        provider.token = ENV['DIGITAL_OCEAN_TOKEN']
        provider.tags =  ['kubernetes', machine[:role], cluster_name_prefix]
        provider.private_networking = true

        override.ssh.private_key_path = "~/.ssh/#{ENV['DIGITAL_OCEAN_PRIVATE_KEY']}"
        override.vm.synced_folder '.', '/vagrant', disabled: true
        override.vm.box = 'digital_ocean'
        override.vm.box_url = 'https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box'
        override.nfs.functional = false

        configure_provision(index, machines, preference, override, {
                              "network_interface": 'eth1',
                              "provider": 'digitalocean',
                              "digital_ocean_token": ENV['DIGITAL_OCEAN_TOKEN'],
                              "use_private_ip_for_external_access": false
                            })
      end
    end
  end
end

def machines_info(preference, provider)
  prefix = ENV.fetch('CLUSTER_NAME_PREFIX', 'k8s')
  machine_defaults = provider_defaults(provider)
  master = merge(machine_defaults.merge({ count: 1 }), preference.fetch(:cluster, {}).fetch(:master, machine_defaults))
  nodes = preference.fetch(:cluster, {}).fetch(:node_pools, [provider_defaults(provider).merge({ count: 1 })])

  machines = []
  machine_index = 0
  (0...master[:count]).each do |index|
      machines << master.merge({ role: 'master', name: "#{prefix}-master-#{index + 1}", virtualbox_private_ip: "10.10.10.#{2 + machine_index}" })
      machine_index += 1
  end

  nodes.each do |node|
    (0...node[:count]).each do |index|
      machine_name = "#{prefix}-node-#{node[:name]}-#{index + 1}"
      machines << merge(machine_defaults, node).merge({ role: 'node', name: machine_name, virtualbox_private_ip: "10.10.10.#{2 + machine_index}" })
      machine_index += 1
    end
  end
  pp machines
  machines
end

Vagrant.configure('2') do |config|
  begin
    preference = symbolize_hash(Psych.load(File.read('cluster.yaml')))
    cluster_default = merge(cluster_defaults, preference[:cluster])
    provider = ENV.fetch('K8S_PROVIDER', cluster_default[:provider])

    machines = machines_info(preference, provider)

    create_vms_on_virtualbox(machines, config, preference) if provider == 'virtualbox'
    create_vms_on_digital_ocean(machines, config, preference) if provider == 'digital_ocean'
  rescue Errno::ENOENT
    puts 'choose provider by running "make use.digitalocean" or "make use.virtualbox"'
    abort
  end
end
