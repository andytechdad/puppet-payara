# Class: payara::java
#
# Manages java installation if required
#
class payara::java {
  # Get the package name based on required java_ver.
  case $payara::java_ver {
    'java-7-oracle'  : {
      # require ::java7
      $java_package = $payara::params::java7_sun_package
    }
    'java-7-openjdk' : {
      $java_package = $payara::params::java7_openjdk_package
    }
    'java-8-oracle'  : {
      $java_package = $payara::params::java8_sun_package
    }
    'java-8-openjdk' : {
      $java_package = $payara::params::java8_openjdk_package
    }
    default          : {
      fail("Unrecognized Java version ${payara::java_ver}. Choose one of: java-7-oracle, java-7-openjdk, java-8-oracle, java-8-openjdk"
      )
    }
  }

  # Install the required package, if set.
  if $java_package {
    package { $java_package: ensure => 'installed' }
  }

}
