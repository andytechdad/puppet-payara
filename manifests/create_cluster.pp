# == Define: payara::create_cluster
#
# Create a payara cluster.
#
# === Parameters
#
# [*asadmin_user*] - Name of asadmin username.
#  Defaults to admin
#
# [*asadmin_passfile*] - Path to asadmin password file.
#  Defaults to '/tmp/asadmin.pass'
#
# [*cluster_name*] - Name of cluster to create.
#  Defaults to the resource name if not specified.
#
# [*cluster_user*] - Name of account running payara cluster.
#  Defaults to $payara::user.
#
# [*dasport*] - Domain Adminsitration Service port.
#  Defaults to '4848'.
#
# [*ensure*] - Cluster ensure state
#  Defaults to present.
#
# [*gms_enabled*] - Should Group Messaging Service (GMS) be enabled.
#  Defaults to true.
#
# [*gms__multicast__port*] - GMS Multicast port.
#  Defaults to undef.
#
# [*gms__multicast__address*] - GMS Multicast address.
#  Defaults to undef.
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
