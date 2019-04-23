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
