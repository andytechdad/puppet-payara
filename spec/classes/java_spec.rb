require 'spec_helper'

# Start to describe glassfish::init class
describe 'glassfish::java' do

  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['7'],
      }
    ]
  }).each do |os, facts|

    context "on #{os}" do
      # Set the osfamily fact
      let(:facts) {
        facts
      }

      describe 'with default params' do
        # Include required class with default param values
        let(:pre_condition) { 'include glassfish' }

        it do
          should contain_package('java-1.7.0-openjdk-devel').with_ensure('installed')
        end
      end

      describe 'with java_ver => java-6-openjdk' do
        # Include required class with default param values
        let(:pre_condition) { 'class {"glassfish":
          java_ver => "java-6-openjdk"}'
        }

        it do
          should contain_package('java-1.6.0-openjdk-devel').with_ensure('installed')
        end
      end

      describe 'with java_ver => java-7-oracle' do
        # Include required class with default param values
        let(:pre_condition) { 'class {"glassfish":
          java_ver => "java-7-oracle"}'
        }

        it do
          should_not contain_package('undef')
        end
      end

      describe 'with java_ver => java-6-oracle' do
        # Include required class with default param values
        let(:pre_condition) { 'class {"glassfish":
          java_ver => "java-6-oracle"}'
        }

        it do
          should_not contain_package('undef')
        end
      end
    end # context "on #{os}"
  end # on_supported_os

  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'Debian',
        'operatingsystemrelease' => ['7'],
      }
    ]
  }).each do |os, facts|

    context "on #{os}" do
      # Set the osfamily fact
      let(:facts) {
        facts
      }

      describe 'with default params' do
        # Include required class with default param values
        let(:pre_condition) { 'include glassfish' }

        it do
          should contain_package('openjdk-7-jdk').with_ensure('installed')
        end
      end
    
      describe 'with java_ver => java-6-openjdk' do
          # Include required class with default param values
          let(:pre_condition) { 'class {"glassfish":
            java_ver => "java-6-openjdk"}' }
    
          it do
            should contain_package('openjdk-6-jdk').with_ensure('installed')
          end
        end

      describe 'with java_ver => java-7-oracle' do
        # Include required class with default param values
        let(:pre_condition) { 'class {"glassfish":
          java_ver => "java-7-oracle"}'
        }

        it do
          should_not contain_package('undef')
        end
      end

      describe 'with java_ver => java-6-oracle' do
        # Include required class with default param values
        let(:pre_condition) { 'class {"glassfish":
          java_ver => "java-6-oracle"}'
        }

        it do
          should contain_package('sun-java6-jdk').with_ensure('installed')
        end
      end
    end # context "on #{os}"
  end # on_supported_os
end
