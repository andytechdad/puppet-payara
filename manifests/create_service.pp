define payara::create_service (
  $domain_name   = undef,
  $cluster_name  = undef,
  $instance_name = undef,
  $node_name     = undef,
  $runuser       = $payara::user,
  $running       = false,
  $mode          = 'domain',
  $das_port      = undef,
  $status_cmd    = undef,
  $service_name  = undef) {
  # Check that we've got a domain name if domain mode.
  if $mode == 'domain' and !$domain_name {
    fail('Domain name must be specified to install service for domain mode.')
  }

  # Check that we've got a cluster name if cluster mode.
  if $mode == 'cluster' and !$cluster_name {
    fail('Cluster name must be specified to install service for cluster mode.')
  }

  # Check that we have a das_port if required
  if $mode == 'cluster' and !$das_port {
    fail('DAS Port must be specified to install service for cluster mode.')
  }

  # Check that we've got a instance name if instance mode.
  if $mode == 'instance' and !$instance_name {
    fail('Instance name must be specified to install service for instance mode.')
  }

  # Check that we've got a node name if instance mode.
  if $mode == 'instance' and !$node_name {
    fail('Node name must be specified to install service for instance mode.')
  }

  # Work out the correct service_name
  if ($service_name == undef) {
    $svc_name = "payara_${title}"
  } else {
    $svc_name = $service_name
  }

  # What service_file should we be using, based on osfamily.
  case $::osfamily {
    'RedHat' : {
      case $mode {
        'domain'   : { $service_file = template('payara/payara-init-domain-el.erb') }
        'cluster'  : { $service_file = template('payara/payara-init-cluster-el.erb') }
        'instance' : { $service_file = template('payara/payara-init-instance-el.erb') }
        default    : { fail("Mode ${mode} not supported.") }
      }
    }
    'Debian' : {
      $service_file = template('payara/payara-init-domain-debian.erb')
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }
  }

  # Create the init file
  file { "${title}_servicefile":
    ensure  => present,
    path    => "/etc/init.d/${svc_name}",
    mode    => '0755',
    content => $service_file,
    notify  => Service[$svc_name]
  }

  # Need to stop the domain if it was auto-started
  if $running {
    exec { "stop_${domain_name}":
      command => "su - ${runuser} -c \"${payara::payara_asadmin_path} stop-domain ${domain_name}\"",
      unless  => "service ${svc_name} status && pgrep -f domains/${domain_name}",
      path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
      before  => Service[$svc_name]
    }
  }

  # Handle different service status options
  if $status_cmd {
    $has_status = false
  } else {
    $has_status = true
  }

  # Make sure the service is running and enabled.
  service { $svc_name:
    ensure     => 'running',
    enable     => true,
    hasstatus  => $has_status,
    hasrestart => true,
    status     => $status_cmd
  }

}
