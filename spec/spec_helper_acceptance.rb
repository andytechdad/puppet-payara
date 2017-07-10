require 'beaker-rspec/spec_helper'
# require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'glassfish')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => 0 }
      on host, puppet('module', 'install', 'puppet-archive'), { :acceptable_exit_codes => 0 }
      on host, puppet('module', 'install', 'camptocamp-systemd'), { :acceptable_exit_codes => 0 }

      # Copy hiera data into default puppet location
      copy_hiera_data_to(host, 'spec/fixtures/hiera/hieradata/')
    end
  end
end
