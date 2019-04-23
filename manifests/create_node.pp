define payara::create_node (
  $asadmin_user     = $payara::asadmin_user,
  $asadmin_passfile = $payara::asadmin_passfile,
  $node_host        = $::hostname,
  $node_name        = $name,
  $node_user        = $payara::user,
  $ensure           = present,
  $das_host         = undef,
  $das_port         = '4848',
  $login            = true) {

  # Create the cluster
  cluster_node { $node_name:
    ensure       => $ensure,
    user         => $node_user,
    asadminuser  => $asadmin_user,
    passwordfile => $asadmin_passfile,
    host         => $node_host,
    dashost      => $das_host,
    dasport      => $das_port
  }

}
