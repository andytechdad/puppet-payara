class payara::install {
  # Create user/group if required
  if $payara::manage_accounts {
    # Create the required group.
    group { $payara::group: ensure => 'present' }

    # Create the required user.
    user { $payara::user:
      ensure     => 'present',
      managehome => true,
      comment    => 'Payara user account',
      gid        => $payara::group,
      require    => Group[$payara::group]
    }
  }

  # Anchor the install class
  anchor { 'payara::install::start': }

  anchor { 'payara::install::end': }

  # Take action based on $install_method.
  case $payara::install_method {
    'zip'     : {
      $payara_download_site = $payara::download_mirror ? {
        undef   => "http://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/$payara::version",
        default => $payara::download_mirror
      }
      $payara_download_file = "payara-$payara::version.zip"
      $payara_download_dest = "${payara::tmp_dir}/${payara_download_file}"

      # Work out major version for installation
      $version_arr             = split($payara::version, '[.]')
      $mjversion               = $version_arr[0]


      # Make sure that $tmp_dir exists.
      file { $payara::tmp_dir:
        ensure  => directory,
        require => Anchor['payara::install::start'],
      }

      # Download file
      exec { "download_${payara_download_file}":
        command => "wget -q ${payara_download_site}/${payara_download_file} -O ${payara_download_dest}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $payara_download_dest,
        timeout => '300',
        require => File[$payara::tmp_dir]
      }

      # Unzip the downloaded payara zip file
      exec { 'unzip-downloaded':
        command => "unzip ${payara_download_dest}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd     => $payara::tmp_dir,
        creates => $payara::payara_dir,
        require => Exec["download_${payara_download_file}"]
      }

      # Chown payara folder.
      exec { 'change-ownership':
        command => "chown -R ${payara::user}:${payara::group} ${payara::tmp_dir}/payara${mjversion}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $payara::payara_dir,
        require => Exec['unzip-downloaded']
      }

      # Make sure that user creation runs before ownership change, IF
      # manage_accounts = true.
      if $payara::manage_accounts {
        User[$payara::user] -> Exec['change-ownership']
      }

      # Chmod payara folder.
      exec { 'change-mode':
        command => "chmod -R g+rwX ${payara::tmp_dir}/payara${mjversion}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $payara::payara_dir,
        require => Exec['change-ownership']
      }

      # Move the payara3 folder.
      exec { "move-payara${mjversion}":
        command => "mv ${payara::tmp_dir}/payara${mjversion} ${payara::payara_dir}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd     => $payara::tmp_dir,
        creates => $payara::payara_dir,
        require => Exec['change-mode']
      }

      if $payara::remove_default_domain {
        # Remove default domain1.
        file { 'remove-domain1':
          ensure  => absent,
          path    => "${payara::payara_dir}/glassfish/domains/domain1",
          force   => true,
          backup  => false,
          require => Exec["move-payara${mjversion}"],
          before  => Anchor['payara::install::end']
        }
      }
    }

    'package' : {
      # Build package from $package_prefix and $version
      $package_name = "${payara::package_prefix}-${payara::version}"

      # Install the package.
      package { $package_name:
        ensure  => present,
        require => Anchor['payara::install::start'],
        before  => Anchor['payara::install::end']
      }

      # Run User/Group create before Package install, If manage_accounts = true.
      if $payara::manage_accounts {
        User[$payara::user] -> Package[$package_name]
      }
    }

    default   : {
      fail("Unrecognised Installation method ${payara::install_method}. Choose one of: 'package','zip'.")
    }
  }

  # Ensure that install runs before any Create_domain & Create_node resources
  Class['payara::install'] -> Payara::Create_domain <| |>
  Class['payara::install'] -> Payara::Create_node <| |>
}
