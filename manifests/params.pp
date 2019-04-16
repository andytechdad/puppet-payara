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
  $payara_install_dir         = undef

  # Default payara temporary directory for downloading Zip.
  $payara_tmp_dir             = '/tmp'

  # RPM Package prefix
  $payara_package_prefix      = 'payara3'

  # Default Payara version
  $payara_version             = '3.1.2.2'

  # Default Payara install parent directory.
  $payara_parent_dir          = '/usr/local'

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
  $payara_asadmin_password    = 'adminadmin'
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

  # Should the payara domain be started upon creation?
  $payara_start_domain        = true

  # Should secure-admin be enabled upon creation?
  $payara_enable_secure_admin = true

  # Payara domain tempalte
  $payara_domain_template     = undef

  # Should the path be updated?
  case $::osfamily {
    'RedHat'  : { $payara_add_path = true }
    'Debian'  : { $payara_add_path = true }
    default : { $payara_add_path = false }
  }

  # Should this module manage Java installation?
  $payara_manage_java = true
  # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk
  $payara_java_ver    = 'java-7-openjdk'

  # Set package names based on Operating System...
  case $::osfamily {
    'RedHat' : {
      $java6_openjdk_package = 'java-1.6.0-openjdk-devel'
      $java6_sun_package     = undef
      $java7_openjdk_package = 'java-1.7.0-openjdk-devel'
      $java7_sun_package     = undef
    }
    'Debian' : {
      $java6_openjdk_package = 'openjdk-6-jdk'
      $java6_sun_package     = 'sun-java6-jdk'
      $java7_openjdk_package = 'openjdk-7-jdk'
      $java7_sun_package     = undef
    }
    default : {
      fail("${::osfamily} not supported by this module.")
    }
  }

  # Clustering config params
  # Enable GMS?
  $payara_gms_enabled       = true

  # Multicase params
  $payara_multicast_port    = undef
  $payara_multicast_address = undef

}
