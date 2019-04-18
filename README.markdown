# Puppet Payara module

Original puppet-glassfish author - Lars Tobias Skjong-Børsting <larstobi@conduct.no>  
Updated by - Gavin Williams <fatmcgav@gmail.com>  
Forked and converted to Payara by - Andy Brown <andy@techdad.tech>

License: GPLv3

####Table of Contents
- [Puppet Payara module](#puppet-payara-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
	- [Usage](#usage)
	- [Limitations](#limitations)
	- [Contributors](#contributors)
	- [Development](#development)
	- [Testing](#testing)

##Overview
This module adds support for installing and managing the Payara J2EE application server.
It supports Payara J2EE version 3.1 and 4.0, running on EL and Debian linux distributions.

##Features
This module can do the following:
 * Install Payara J2EE Application server, either by downloading a Zip file
 or installing from a package.
 * Install and configure Java if appropriate.
 * Manage user accounts if appropriate.
 * Configure PATH to support Payara.
 * Create Linux service to run Payara on system startup.
 * Create asadmin password files for different users or locations.
 * Install additional JARs if appropriate.
 * Create and manage Payara clusters, including:
  * Domain Administration Service (DAS)
  * Nodes
  * Instances
 * Manage various configuration elements of Payara, including:
  * Applications
  * Auth Realm
  * Custom Resources
  * Log Attribute properties
  * Javamail Resources
  * JDBC Connection Pools
  * JDBC Resources
  * JMS Resources
  * JVM Options
  * Network Listeners
  * Resource references
  * Set options
  * System properties

Further features that are likely to be added include:
 * ~~Additional support for Cluster environments, such as targeting resources at cluster.~~

##Requirements
This module requires the Puppetlabs-Stdlib module >= 3.2.0.

##Usage
Payara can be installed and configured with a default configuration with:  
```puppet
include payara
```
This will install Java 8 OpenJDK, create a Payara group and user account,
download and install Payara J2EE 5.191 using a Zip file. No domains are created by default.

To install Payara using a package manager, such as yum or apt, you could do:
```puppet
class { 'payara':
  install_method => 'package',
  package_prefix => 'payara'
}
```
_package_prefix_ can be used to change the package naming structure.
The required version is appended to the end to form the package name, e.g.: `payara3-3.1.2.2`

To create and configure a domain upon installation, you could do:
```puppet
class { 'payara':
  create_domain => true,
  domain_name   => 'gf_domain',
  portbase      => '8000'
}
```
This will install Payara and create a domain called 'gf_domain' using portbase 8000,
with a default username/password of '_admin/letmein1_'.

If you are using other means to manage user accounts on this host,
then you can stop this module managing user accounts by doing:
```puppet
class { 'payara':
  manage_accounts => false
}
```

This module also provides several defined types which can be used to simplify other tasks,
such as creating a domain using `payara::create_domain` to create a new domain,
or `payara::create_cluster` to create a new cluster.  

It is also possible to use the types directly.   
E.g.
```puppet
  jdbcconnectionpool { 'ConPool':
    ensure       => present,
    resourcetype => 'javax.sql.ConnectionPoolDataSource',
    dsclassname  => 'oracle.jdbc.pool.OracleConnectionPoolDataSource',
    properties   => {
      'user'     => 'con_user',
      'password' => 'con_password',
      'url'      => 'jdbc\:oracle\:thin\:@localhost\:1521\:XE'
    },
    portbase     => '8000',
    asadminuser  => 'admin',
    user         => 'payara'
  }

  jdbcresource { 'jdbc/ConPool':
    ensure         => present,
    connectionpool => 'ConPool',
    portbase       => '8000',
    target         => 'aCluster',
    asadminuser    => 'admin',
    user           => 'payara'
  }
```

##Limitations
This module has primarily been developed and tested on CentOS 6.
It has also been lightly tested on Debian and Ubuntu, so should support most common Linux distributions.

##Development
If you have any features that you feel are missing or find any bugs for this module,
feel free to raise an issue on [Github](https://github.com/andytechdad/puppet-payara/issues?state=open),
or even better submit a PR and I will review as soon as I can.

##Testing
This module has been written to support Rspec testing of both the manifests and types/providers.
In order to execute the tests, run the following from the root of the module:
 `bundle install && bundle exec rake spec`  
