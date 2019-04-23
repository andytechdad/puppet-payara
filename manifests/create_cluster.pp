define payara::create_cluster (
  $asadmin_user          = $payara::asadmin_user,
  $asadmin_passfile      = $payara::asadmin_passfile,
  $cluster_name          = $name,
  $cluster_user          = $payara::user,
  $das_port              = '4848',
  $ensure                = present,
  $gms_enabled           = $payara::gms_enabled,
  $gms_multicast_port    = $payara::gms_multicast_port,
  $gms_multicast_address = $payara::gms_multicast_address) {

  # Create the cluster
  cluster { $cluster_name:
    ensure           => $ensure,
    user             => $cluster_user,
    asadminuser      => $asadmin_user,
    passwordfile     => $asadmin_passfile,
    dasport          => $das_port,
    gmsenabled       => $gms_enabled,
    multicastport    => $gms_multicast_port,
    multicastaddress => $gms_multicast_address
  }

}
