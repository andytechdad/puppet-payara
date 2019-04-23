define payara::create_asadmin_passfile (
  $group,
  $path,
  $user,
  $asadmin_master_password = 'changeit',
  $asadmin_password = 'letmein1') {
  # Create the required passfile
  file { $name:
    ensure  => present,
    path    => $path,
    content => template('payara/passwordfile'),
    owner   => $user,
    group   => $group,
    mode    => '0600'
  }

}
