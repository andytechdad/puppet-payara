# == Define: payara::install_jars
#
# Install additional jars if required.
#
# === Parameters
#
# [*domain_name*] - Name of domain to install jar into.
#  Required if `install_location' = domain`.
#
# [*download*] - Should the jar be downloaded?
#  Defaults to false.
#
# [*install_location*] - Where to install the jar.
#  Defaults to 'installation'. Can also be 'domain' or 'mq'.
#
# [*service_name*] - Service name of domain to notify
#  Required if `install_location' = 'domain` and a non-standard
#  service name is being used.
#
# [*source*] - Source to copy jar file from.
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
define payara::install_jars (
  $domain_name      = undef,
  $download         = false,
  $install_location = 'installation',
  $service_name     = undef,
  $source           = '') {
  # Set some required vars
  $jaraddress = $name
  $jar        = basename($jaraddress)

  # Check domain name if install_location = 'domain'
  if ($install_location == 'domain') {
    # Set $service.
    if ($service_name == undef) {
      # Check if top-level svc_name is set
      if ($payara::svc_name == undef) {
        # Assume that the service name is of default format - payara_${domain_name}
        $service = "Service[payara_${domain_name}]"
      } else {
        # Use top-level $svc_name value
        $service = "Service[${payara::svc_name}]"
      }
    } else {
      # Use $service_name value that was provided
      $service = "Service[${service_name}]"
    }
  }

  # Where do we need to install the jar, and do we need to notify a service?
  case $install_location {
    'domain'       : {
      $jardest = "${payara::payara_dir}/payara/domains/${domain_name}/lib/ext/${jar}"
      $notify  = $service
    }
    'installation' : {
      $jardest = "${payara::payara_dir}/payara/lib/ext/${jar}"
      $notify  = undef
    }
    'mq'           : {
      $jardest = "${payara::payara_dir}/mq/lib/ext/${jar}"
      $notify  = undef
    }
    default        : {
      fail("Install location ${install_location} is not supported.")
    }
  }

  # Create the lib/ext folder if required
  if ($install_location == 'installation') {

    # Use ensure_resource to avoid duplicate declaration issues...
    ensure_resource('file',
    "${payara::payara_dir}/payara/lib/ext",
    {
      'ensure' => 'directory',
      'owner'  => $payara::user,
      'group'  => $payara::group
    })

    if ($download) {
      File["${payara::payara_dir}/payara/lib/ext"] -> Exec["download_${jar}"]
    } else {
      File["${payara::payara_dir}/payara/lib/ext"] -> File[$jardest]
    }
  }

  # Download or copy the file?
  if $download {
    exec { "download_${jar}":
      command => "wget -q -O ${jardest} ${jaraddress}",
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      creates => $jardest,
      user    => $payara::user,
      notify  => $notify
    }
  } else {
    file { $jardest:
      ensure => present,
      mode   => '0755',
      owner  => $payara::user,
      group  => $payara::group,
      source => $source,
      notify => $notify
    }

  }

  # Add dependencies to ensure runs after domain is created if installing to domain
  if ($install_location == 'domain') {
    Domain <| title == $domain_name |> -> Payara::Install_jars <| install_location == 'domain' |>
  }

}
