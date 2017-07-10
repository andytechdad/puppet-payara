require 'spec_helper'

# Start to describe glassfish::path class
describe 'glassfish::path' do
  
  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '6'
    } }

    # Include required classes
    let(:pre_condition) { 'include glassfish' }
    
    it do 
      should contain_file('/etc/profile.d/glassfish.sh').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' =>  /glassfish/
      }).that_requires('Class[glassfish::install]')
    end
  end
  
  context 'on a Debian OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Debian'
    } }
    
    # Include required classes
    let(:pre_condition) { 'include glassfish' }

    it do 
      should contain_file('/etc/profile.d/glassfish.sh').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' =>  /glassfish/
      }).that_requires('Class[glassfish::install]')
    end
  end
  
  context 'on an unsupport OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Suse'
    } }
    
    it do 
      should compile.and_raise_error(/OSFamily Suse is not currently supported./)
    end
  end
  
end
