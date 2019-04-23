# == Define: payara::create_instance
#
# Create a payara cluster instance.
#
# === Parameters
#
# [*asadmin_user*] - Name of asadmin username.
#  Defaults to admin
#
# [*asadmin_passfile*] - Path to asadmin password file.
#  Defaults to '/tmp/asadmin.pass'
#
# [*cluster*] - Cluster to create instance against.
#  Defaults to undef
#
# [*create_service*] - Create a service for this instance.
#  Defaults to $payara::create_service
#
# [*das_host*] - Domain Adminsitration Service host.
#  Defaults to undef
#
# [*das_port*] - Domain Adminsitration Service port.
#  Defaults to '4848'
#
# [*instance_name*] - Name of instance to create.
#  Defaults to $name
#
# [*instance_portbase*] - Portbase to create instance on.
#  Defaults to undef
#
# [*node_name*] - Name of node to associate instance with.
#  Defaults to $::hostname
#
# [*node_user*] - Username node is running under.
#  Defaults to $payara::user
#
# [*service_name*] - Specify a custom service name.
#  Defaults to `payara_${instance_name}`
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
define payara::create_instance (
  $asadmin_user      = $payara::asadmin_user,
  $asadmin_passfile  = $payara::asadmin_passfile,
  $cluster           = undef,
  $create_service    = $payara::create_service,
  $das_host          = undef,
  $das_port          = '4848',
  $ensure            = present,
  $instance_name     = $name,
  $instance_portbase = undef,
  $node_name         = $::hostname,
  $node_user         = $payara::user,
  $service_name      = $payara::service_name) {

  # Service name
  if ($service_name == undef) {
    $svc_name = "payara_${instance_name}"
  } else {
    $svc_name = $service_name
  }

  # Create the cluster
  cluster_instance { $instance_name:
    ensure       => $ensure,
    user         => $node_user,
    asadminuser  => $asadmin_user,
    passwordfile => $asadmin_passfile,
    dashost      => $das_host,
    dasport      => $das_port,
    nodename     => $node_name,
    cluster      => $cluster,
    portbase     => $instance_portbase
  }

  # Create a init.d service if required
  if $create_service {
    payara::create_service { $instance_name:
      mode          => 'instance',
      instance_name => $instance_name,
      node_name     => $node_name,
      runuser       => $node_user,
      service_name  => $svc_name,
      require       => Cluster_Instance[$instance_name]
    }
  }

}
