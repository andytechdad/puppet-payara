require 'spec_helper'

# Start to describe glassfish::init class
describe 'glassfish' do

  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => '6',
      :path                      => "/home/vagrant/vendor/bundler/ruby/1.8/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/var/lib/gems/1.8/bin/:/usr/local/bin:/root/.gem/ruby/2.1.0/bin:/usr/lib64/ruby/gems/1.9.1/gems/bundler-1.7.12/bin:/usr/lib64/ruby/gems/2.0.0/gems/bundler-1.7.12/bin",
      :systemd                   => false
    } }

    describe 'with default param values' do
      #
      ## Test default behaviour
      #
      it do
        # Should compile
        should compile.with_all_deps()

        # Classes
        should create_class('glassfish')
        should contain_class('glassfish::params')

        # Parent dir
        should contain_file('/usr/local').with_ensure('directory')

        # Manage_java defaults to false
        should contain_class('glassfish::java').that_comes_before('Class[glassfish::install]')

        # Should create a password file
        should contain_glassfish__create_asadmin_passfile('glassfish_asadmin_passfile').with({
          'asadmin_master_password' => 'changeit',
          'asadmin_password'        => 'adminadmin',
          'group'                   => 'glassfish',
          'path'                    => '/home/glassfish/asadmin.pass',
          'user'                    => 'glassfish'
        }) # TODO: Add a fixture for the default asadmin.passfile

        # Should include install
        should contain_class('glassfish::install').that_requires('File[/usr/local]')

        # Create_domain defaults to false
        should_not contain_create_domain('domain1')

        # Should include path class
        should contain_class('glassfish::path').that_requires('Class[glassfish::install]')
      end
    end

    describe 'with manage_java => false' do
      # Set relevant params
      let(:params) do {
          :manage_java => false
        }
      end

      # Shouldn't include glassfish::java class
      it { should_not contain_class('glassfish::java') }
    end

    describe 'with create_domain => true and domain_name => domain' do
      # Set relevant params
      let(:params) do  {
          :create_domain => true,
          :domain_name   => 'domain'
        }
      end

      it do
        # Should contain asadmin_passfile with ordering
        should contain_glassfish__create_asadmin_passfile('glassfish_asadmin_passfile').that_comes_before('Glassfish::Create_domain[domain]')

        # Should include create_domain resource
        should contain_glassfish__create_domain('domain').that_requires('Class[glassfish::install]')
        should contain_domain('domain').with({
          'ensure'            => 'present',
          'user'              => 'glassfish',
          'asadminuser'       => 'admin',
          'passwordfile'      => '/home/glassfish/asadmin.pass',
          'portbase'          => '4800',
          'startoncreate'     => true,
          'enablesecureadmin' => true,
          'template'          => nil
        })

        # Should not include install_jars resource
        should_not contain_install_jars('[]')

        # Should include create_service resource
        should contain_glassfish__create_service('domain')
        should contain_file('domain_servicefile').with({
          'ensure' => 'present',
          'path'   => '/etc/init.d/glassfish_domain',
          'mode'   => '0755'
        }).that_notifies('Service[glassfish_domain]') # TODO: Add fixture for sample init.d content
        should contain_exec('stop_domain').with({
          'command' => 'su - glassfish -c "/usr/local/glassfish-3.1.2.2/bin/asadmin stop-domain domain"',
          'unless'  => 'service glassfish_domain status && pgrep -f domains/domain',
          'path'    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
        }).that_comes_before('Service[glassfish_domain]')
        should contain_service('glassfish_domain').with({
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => true,
          'status'     => nil
        })

      end
    end

    describe 'with create_domain => true, default domain name and remove_default_domain => true' do
      # Set relevant params
      let(:params) do {
          :create_domain => true,
          :domain_name   => 'domain1'
        }
      end

      # Should  fail due to invalid boolean
      it do
        should compile.and_raise_error(/creating 'domain1' and removing default domain 'domain1' together makes no sense/)
      end
    end

    describe 'with a different asadmin_passfile_path specified' do
      # Set relevant params
      let(:params) do {
          :asadmin_passfile => '/tmp/asadmin.pass'
        }
      end

      # Should create a password file in /tmp/asadmin.pass
      it do
        should contain_glassfish__create_asadmin_passfile('glassfish_asadmin_passfile').with({
          'asadmin_master_password' => 'changeit',
          'asadmin_password'        => 'adminadmin',
          'group'                   => 'glassfish',
          'path'                    => '/tmp/asadmin.pass',
          'user'                    => 'glassfish'
        }) # TODO: Add a fixture for the default asadmin.passfile
      end
    end
    
    describe 'with add_path => false' do
      # Set relevant params
      let(:params) do {
          :add_path => false
        }
      end

      # Shouldn't contain glassfish::path class
      it do
        should_not contain_class('glassfish::path')
      end
    end

    describe 'with invalid param' do
      # Set relevant params
      let(:params) do {
          :create_domain => 'blah'
        }
      end

      # Should  fail due to invalid boolean
      it do
        should compile.and_raise_error(/is not a boolean/)
      end
    end
    
    describe 'with create_passfile => false' do 
      # Set relevant params
      let(:params) do {
          :create_passfile => false
        }
      end

      # Shouldn't contain glassfish::path class
      it do
        should_not contain_glassfish__create_asadmin_passfile('/home/glassfish/asadmin.pass')
      end
      
    end
  end
end
