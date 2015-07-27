# -+- mode: ruby -+-
# vim: set ts=2 softtabstop=2 expandtab shiftwidth=2:
#
# == vsphere_multihost
#
# This vagrant box is made to manage multiple servers in a VMware vSphere
# (ESXi) environment without having to touch a single line of ruby.
#
# All setup is done via YAML files
#
# === Requirements
#
# Requires following plugins:
#
#   * vagrant-vsphere
#   * vagrant-librarian-puppet
#
# === settings.yaml
#
# Content of this file is a `hosts` hash containing a list of hosts. Should
# look similar to the following:
#
#   ---
#   hosts:
#     - name: puppet
#       bootstrap: './scripts/puppet.sh'
#     - name: rackmaster1
#       ipaddr: 10.0.0.2
#       gateway: 10.0.0.1
#
# The various parameters each host can use are the exact ones from the
# vagrant-vsphere plugin by nsidc with a couple custom ones. Custom ones are:
#
#   bootstrap: path to shell script to run on host during provisioning
#   provision: if set to 'puppet' on host, will use puppet to provision and
#              look for the host entry manifest at `manifests/[name].pp`
#   hiera:     path to hiera config file if you want to use hiera with puppet.
#
require 'yaml'

# Load settings from yaml
settings = YAML.load_file('./settings.yaml')
vcenter = settings['vcenter']
hosts = settings['hosts']

# Minimum Vagrant versions
Vagrant.require_version '>= 1.6.0'
VAGRANTFILE_API_VERSION = '2'
 
# Start creating servers
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Iterate through yaml hosts
  hosts.each do |host|
    # host keys: [name, box, mem, cpu, spec, ipaddr, gateway, bootstrap]

    # Enter specific host setup
    config.vm.define host['name'] do |srv|

      srv.vm.box = 'vsphere_connect'
      srv.vm.hostname = host['name']

      # Enter vsphere setup for new host
      srv.vm.provider :vsphere do |vsphere|

        # Connect to vcenter server
        vsphere.host = vcenter['host']
        vsphere.user = vcenter['user']
        vsphere.password = vcenter['password']
        if vcenter.has_key?('insecure')
          vsphere.insecure = vcenter['insecure']
        end

        # Start conditionally checking provided arguments through YAML and
        # setting vsphere values
        if host.has_key?('data_center_name')
            vsphere.data_center_name = host['data_center_name']
        end

        if host.has_key?('compute_resource_name')
            vsphere.compute_resource_name = host['compute_resource_name']
        end

        if host.has_key?('resource_pool_name')
            vsphere.resource_pool_name = host['resource_pool_name']
        end

        if host.has_key?('clone_from_vm')
            vsphere.clone_from_vm = host['clone_from_vm']
        end

        if host.has_key?('template_name')
            vsphere.template_name = host['template_name']
        end

        if host.has_key?('vm_base_path')
            vsphere.vm_base_path = host['vm_base_path']
        end

        if host.has_key?('name')
            vsphere.name = host['name']
        end

        # Allow spec as shorthand for customization_spec_name
        if host.has_key?('customization_spec_name')
          vsphere.customization_spec_name = host['customization_spec_name']
        elsif host.has_key?('spec')
          vsphere.customization_spec_name = host['spec']
        end

        if host.has_key?('data_store_name')
            vsphere.data_store_name = host['data_store_name']
        end

        if host.has_key?('linked_clone')
            vsphere.linked_clone = host['linked_clone']
        end

        if host.has_key?('proxy_host')
            vsphere.proxy_host = host['proxy_host']
        end

        if host.has_key?('proxy_port')
            vsphere.proxy_port = host['proxy_port']
        end

        if host.has_key?('vlan')
            vsphere.vlan = host['vlan']
        end

        # allow mem for shorthand for memory_mb
        if host.has_key?('memory_mb')
            vsphere.memory_mb = host['memory_mb']
        elsif host.has_key?('mem')
            vsphere.memory_mb = host['mem']
        end

        # Allow cpu as shorthand for cpu_count
        if host.has_key?('cpu_count')
            vsphere.cpu_count = host['cpu_count']
        elsif host.has_key?('cpu')
            vsphere.cpu_count = host['cpu']
        end

        if host.has_key?('mac')
            vsphere.mac = host['mac']
        end

        if host.has_key?('cpu_reservation')
            vsphere.cpu_reservation = host['cpu_reservation']
        end

        if host.has_key?('mem_reservation')
            vsphere.mem_reservation = host['mem_reservation']
        end

        if host['provision'] == 'puppet'
          config.librarian_puppet.puppetfile_dir = 'puppet'
          srv.vm.provision 'puppet' do |puppet|
            puppet.manifests_path = 'puppet/manifests'
            puppet.manifest_file = "#{host['name']}.pp"
            # puppet.manifest_file = "default.pp"
            puppet.module_path = 'puppet/modules'
            puppet.facter = {
              'vagrant' => '1'
            }
            if host.has_key?('hiera')
              puppet.hiera_config_path = host['hiera']
              puppet.working_directory = '/tmp/vagrant-puppet'
            end
          end
        end

        # Don't try to set IP if not provided. If provided, spec must be too
        if host.has_key?('ipaddr')
          gateway = host['gateway']
          srv.vm.network 'private_network', 
            ip: host['ipaddr']
          srv.vm.provision 'shell',
            run: 'always',
            inline: "ip route delete default 2>&1 > /dev/null || true; ip route add default via #{gateway}"
        end

        # Allow for a bootstrap shell script passed via YAML
        if host.has_key?('bootstrap')
          srv.vm.provision :shell,
            :path => host['bootstrap']
        end

      end
    end
  end
end
