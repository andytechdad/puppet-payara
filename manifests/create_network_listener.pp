define payara::create_network_listener (
  $ensure            = present,
  $address           = undef,
  $port              = undef,
  $threadpool        = undef,
  $protocol          = undef,
  $transport         = 'tcp',
  $enabled           = true,
  $jkenabled         = false,
  $target            = server,
  $asadmin_path      = $payara::payara_asadmin_path,
  $asadmin_user      = $payara::asadmin_user,
  $asadmin_passfile  = $payara::asadmin_passfile,
  $portbase          = $payara::portbase,
  $user              = $payara::user
) {

  # Create
  networklistener { $name:
    ensure       => $ensure,
    address      => $address,
    port         => $port,
    threadpool   => $threadpool,
    protocol     => $protocol,
    transport    => $transport,
    enabled      => $enabled,
    jkenabled    => $jkenabled,
    target       => $target,
    asadminuser  => $asadmin_user,
    passwordfile => $asadmin_passfile,
    portbase     => $portbase,
    user         => $user
  }
}
