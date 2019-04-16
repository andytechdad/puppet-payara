# == Class: payara::path
#
# Add payara to profile
#
# === Parameters
#
# None
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
class payara::path {
  case $::osfamily {
    'RedHat' : {
      # Add a file to the profile.d directory
      file { '/etc/profile.d/payara.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('payara/payara-profile-el.erb'),
        require => Class['payara::install']
      }
    }
    'Debian' : {
      # Add a file to the profile.d directory
      file { '/etc/profile.d/payara.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('payara/payara-profile-deb.erb'),
        require => Class['payara::install']
      }
    }
    default  : {
      fail("OSFamily ${::osfamily} is not currently supported.")
    }
  }

  # Ensure payara::path runs before any resources that require asadmin
  Class['payara::path'] -> Payara::Create_domain <| |>
  Class['payara::path'] -> Payara::Create_cluster <| |>
  Class['payara::path'] -> Payara::Create_node <| |>

}
