# == Define: payara::create_domain
#
# Create a payara domain on installation.
#
# === Parameters
#
# [*asadmin_path*] - Path to asadmin binary.
#  Defaults to $payara::payara_asadmin_path
#
# [*asadmin_user*] - Asadmin username.
#  Defaults to $payara::asadmin_user
#
# [*asadmin_passfile*] - Asadmin password file.
#  Defaults to $payara::asadmin_passfile
#
# [*create_service*] - Should a service init file be created?
#  Defaults to $payara::start_domain
#
# [*domain_template*] - Domain template to use.
#  Defaults to $payara::domain_template
#
# [*domain_name*] - Name of domain to create.
#  Defaults to the resource name if not specified
#
# [*domain_user*] - User account under which to run domain.
#  Defaults to $payara::user
#
# [*enable_secure_admin*] - Enable secure admin on domain.
#  Defaults to the $payara::enable_secure_admin
#
# [*portbase*] - Portbase to use for domain.
#  Defaults to $payara::portbase
#
# [*service_name*] - Specify a custom service name.
#  Defaults to `payara_${domain_name}`
#
# [*start_domain*] - Should the domain be started upon creation?
#  Defaults to $payara::start_domain
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
define payara::create_domain (
  $asadmin_path        = $payara::payara_asadmin_path,
  $asadmin_user        = $payara::asadmin_user,
  $asadmin_passfile    = $payara::asadmin_passfile,
  $create_service      = $payara::create_service,
  $domain_name         = $name,
  $domain_template     = $payara::domain_template,
  $domain_user         = $payara::user,
  $enable_secure_admin = $payara::enable_secure_admin,
  $ensure              = present,
  $portbase            = $payara::portbase,
  $service_name        = $payara::service_name,
  $start_domain        = $payara::start_domain) {
  # Service name
  if ($service_name == undef) {
    $svc_name = "payara_${domain_name}"
  } else {
    $svc_name = $service_name
  }

  # Create the domain
  domain { $domain_name:
    ensure            => $ensure,
    user              => $domain_user,
    asadminuser       => $asadmin_user,
    passwordfile      => $asadmin_passfile,
    portbase          => $portbase,
    startoncreate     => $start_domain,
    enablesecureadmin => $enable_secure_admin,
    template          => $domain_template
  }

  # Create a init.d service if required
  if $create_service {
    payara::create_service { $domain_name:
      running      => $start_domain,
      mode         => 'domain',
      domain_name  => $domain_name,
      service_name => $svc_name,
      runuser      => $domain_user,
      require      => Domain[$domain_name]
    }
  }

  # Run Create_domain resources before Create_cluster and Create_node resources
  Payara::Create_domain <| |> -> Payara::Create_cluster <| |>
  Payara::Create_domain <| |> -> Payara::Create_node <| |>

}
