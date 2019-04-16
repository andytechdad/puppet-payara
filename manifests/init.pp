# == Class: payara
#
# This module manages payara
#
# === Parameters
#
#  [*add_path*] - Should payara bin be added to path?
#  Defaults to true
#
#  [*asadmin_user*] - Asadmin username.
#  Defaults to 'admin'
#
#  [*asadmin_passfile*] - Asadmin password file.
#  Defaults to '/home/payara/asadmin.pass'
#
#  [*asadmin_master_password*] - Asadmin master password.
#  Defaults to 'changeit'
#
#  [*asadmin_password*] - Asadmin password.
#  Defaults to 'adminadmin'
#
#  [*create_domain*] - Should a payara domain be created on installation?
#  Defaults to false
#
#  [*create_service*] - Should a payara service be created on installation?
#  Defaults to true
#
#  [*create_passfile*] - Should a payara password file be created?
#  Defaults to true
#
#  [*domain_name*] - Glassfish domain name. Defaults to 'domain1'.
#
#  [*domain_template*] - Glassfish domain template to use.
#
#  [*download_mirror*] - Glassfish zip file download mirror.
#
#  [*enable_secure_admin*] - Should secure admin be enabled?
#  Defaults to true
#
#  [*gms_enabled*] - Should Group Messaging Service be enabled for cluster.
#
#  [*gms_multicast_port*] - GMS Multicast port.
#
#  [*gms_multicast_address*] - GMS Multicast address.
#
#  [*group*] - Glassfish group name.
#
#  [*install_method*]  - Glassfish installation method.
#  Can be: 'zip', 'package'. Defaults to 'zip'.
#
#  [*java_ver*]        - Java version to install if managing Java.
#
#  [*manage_accounts*] - Should this module manage user accounts and groups
#  required for Glassfish? Defaults to true.
#
#  [*manage_java*]     - Should Java installation be managed by this module?
#  Defaults to true.
#
#  [*package_prefix*]  - Glassfish package name prefix. Defaults to
#  'payara3'.
#
#  [*parent_dir*]      - Glassfish parent directory. Defaults to '/usr/local'.
#
#  [*portbase*]        - Glassfish portbase. Used when creating a domain on install.
#  Defaults to '4800'
#
#  [*remove_default_domain*] - Should the default domain doiman1' be removed on install?
#  Defaults to true.
#
#  [*start_domain*] - Should the payara domain be started on creation?
#  Defaults to true
#
#  [*tmp_dir*]         - Glassfish temporary directory. Defaults to '/tmp'.
#  Only used if installing using zip method.
#
#  [*user*]            - Glassfish user name.
#
#  [*version*]         - Glassfish version, defaults to '3.1.2.2'.
#
# === Examples
#
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#
class payara (
  $add_path                = $payara::params::payara_add_path,
  $asadmin_user            = $payara::params::payara_asadmin_user,
  $asadmin_passfile        = $payara::params::payara_asadmin_passfile,
  $asadmin_master_password = $payara::params::payara_asadmin_master_password,
  $asadmin_password        = $payara::params::payara_asadmin_password,
  $create_domain           = $payara::params::payara_create_domain,
  $create_service          = $payara::params::payara_create_service,
  $create_passfile         = $payara::params::payara_create_passfile,
  $domain_name             = $payara::params::payara_domain,
  $domain_template         = $payara::params::payara_domain_template,
  $download_mirror         = undef,
  $enable_secure_admin     = $payara::params::payara_enable_secure_admin,
  $gms_enabled             = $payara::params::payara_gms_enabled,
  $gms_multicast_port      = $payara::params::payara_multicast_port,
  $gms_multicast_address   = $payara::params::payara_multicast_address,
  $group                   = $payara::params::payara_group,
  $install_dir             = $payara::params::payara_install_dir,
  $install_method          = $payara::params::payara_install_method,
  $java_ver                = $payara::params::payara_java_ver,
  $manage_accounts         = $payara::params::payara_manage_accounts,
  $manage_java             = $payara::params::payara_manage_java,
  $package_prefix          = $payara::params::payara_package_prefix,
  $parent_dir              = $payara::params::payara_parent_dir,
  $portbase                = $payara::params::payara_portbase,
  $remove_default_domain   = $payara::params::payara_remove_default_domain,
  $service_name            = $payara::params::payara_service_name,
  $start_domain            = $payara::params::payara_start_domain,
  $tmp_dir                 = $payara::params::payara_tmp_dir,
  $user                    = $payara::params::payara_user,
  $version                 = $payara::params::payara_version
  ) inherits payara::params {
  #
  ## Calculate some vars based on passed parameters
  #
  # Installation location
  if ($install_dir == undef) {
    $payara_dir = "${parent_dir}/payara-${version}"
  } else {
    $payara_dir = "${parent_dir}/${install_dir}"
  }

  # Asadmin path
  $payara_asadmin_path = "${payara_dir}/bin/asadmin"

  # Validate passed paramater values
  validate_bool($add_path)
  validate_bool($create_domain)
  validate_bool($create_service)
  validate_bool($create_passfile)
  validate_bool($start_domain)
  validate_bool($enable_secure_admin)
  validate_string($asadmin_user)
  validate_string($domain_name)
  validate_string($group)
  validate_string($install_method)
  validate_bool($manage_accounts)
  validate_bool($manage_java)
  validate_string($package_prefix)
  validate_string($user)


  if $remove_default_domain and $create_domain {
      if $domain_name == 'domain1' {
        fail("creating 'domain1' and removing default domain 'domain1' together makes no sense")
      }
  }

  #
  ## Start to run through the install process
  #

  # Ensure that the $parent_dir exists
  file { $parent_dir: ensure => directory }

  # Do we need to manage Java?
  if $manage_java {
    class { 'payara::java': before => Class['payara::install'] }
  }

  # Should we create a passfile?
  if $create_passfile {
    # Create a passfile
    payara::create_asadmin_passfile { "${user}_asadmin_passfile":
      asadmin_master_password => $asadmin_master_password,
      asadmin_password        => $asadmin_password,
      group                   => $group,
      path                    => $asadmin_passfile,
      user                    => $user
    }

    # Run this before any resources that require it
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Glassfish::Create_domain <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Glassfish::Create_cluster <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Glassfish::Create_node <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Glassfish::Create_instance <| |>
  }

  # Call the install method
  include payara::install

  # Make sure parent_dir runs before payara::install.
  File[$parent_dir] -> Class['payara::install']

  # Need to manage path?
  if $add_path {
    class { 'payara::path': require => Class['payara::install'] }

    # Setup path before creating the domain...
    if $create_domain {
      Class['payara::path'] -> Glassfish::Create_domain[$domain_name]
    }
  }

  # Do we need to create a domain on installation?
  if $create_domain {
    # Validate params required for domain creation
    validate_string($domain_name)
    validate_absolute_path($asadmin_passfile)

    # Service name
    if ($service_name == undef) {
      $svc_name = "payara_${domain_name}"
    } else {
      $svc_name = $service_name
    }

    # Need to create the required domain
    payara::create_domain { $domain_name: require => Class['payara::install'] }

  }

}
