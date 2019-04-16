# == Class: payara::params
#
# This class manages payara module params.
#
# === Parameters
#
#  None
#
# === Examples
#
# Not applicable
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#

class payara::params {
  # Installation method. Can be: 'package','zip'.
  $payara_install_method      = 'zip'

  # Default payara install location
  $payara_install_dir         = 'payara5'

  # Default payara temporary directory for downloading Zip.
  $payara_tmp_dir             = '/tmp'

  # RPM Package prefix
  $payara_package_prefix      = 'payara'

  # Default Payara version
  $payara_version             = '5.181'

  # Default Payara install parent directory.
  $payara_parent_dir          = '/opt'

  # Should Payara manage user accounts/groups?
  $payara_manage_accounts     = true
  # Default Payara User
  $payara_user                = 'payara'
  # Default Payara Group
  $payara_group               = 'payara'

  # Should the included default 'domain1' be removed?
  $payara_remove_default_domain = true

  # Default Payara asadmin username
  $payara_asadmin_user        = 'admin'
  # Default Payara asadmin password file
  $payara_asadmin_passfile    = '/home/payara/asadmin.pass'
  # Default Payara asadmin master password
  $payara_asadmin_master_password = 'changeit'
  # Default Payara asadmin password
  $payara_asadmin_password    = 'letmein1'
  # Should a passfile be created?
  $payara_create_passfile     = true

  # Should a payara domain be created on installation?
  $payara_create_domain       = false
  # Should a payara service be created on installation?
  $payara_create_service      = true
  # Default Payara domain, portbase and profile
  $payara_domain              = undef
  $payara_portbase            = '4800'
  # Default Payara service name
  $payara_service_name        = undef
  # Default Payara service enable
  $payara_service_enable      = true
  # Default Payara service status
  $payara_service_status      = 'enabled'

  # Should the payara domain be started upon creation?
  $payara_start_domain        = true

  # Should secure-admin be enabled upon creation?
  $payara_enable_secure_admin = true

  # Payara domain tempalte
  $payara_domain_template     = undef

  # Should Payara be restarted on config change?
  $restart_config_change = true

  # Should the path be updated?
  case $facts['os']['family'] {
    'RedHat'  : { $payara_add_path = true }
    default : { $payara_add_path = false }
  }

  # Should this module manage Java installation?
  $payara_manage_java = true
  $payara_java_ver    = 'java-8-openjdk'

  # Set package names based on Operating System...
  case $facts['os']['family'] {
    'RedHat' : {
      $java8_openjdk_package = 'java-1.8.0-openjdk-devel'
      $java8_sun_package     = undef
      $java7_openjdk_package = 'java-1.7.0-openjdk-devel'
      $java7_sun_package     = undef
    }
    default : {
      fail("${facts['os']['family']} not supported by this module.")
    }
  }

  # Service provider
  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'OracleLinux': {
      if versioncmp($facts['os']['release']['major'], '7') >= 0 {
        $service_domain_template   = 'systemd/domain.service.erb'
        $service_instance_template = 'systemd/instance.service.erb'
        $service_provider          = 'systemd'
        $systemd_service_path      = '/lib/systemd/system'
      } else {
        $service_domain_template   = 'init/domain-el.service.erb'
        $service_instance_template = 'init/instance-el.service.erb'
        $service_provider          = 'init'
        $systemd_service_path      = undef
      }
    }
    default: {
      fail("\"${module_name}\" provides no service parameters for \"${facts['os']['release']['name']}\"")
    }
  }

  # Clustering config params
  # Enable GMS?
  $payara_gms_enabled       = true

  # Multicase params
  $payara_multicast_port    = undef
  $payara_multicast_address = undef

}
