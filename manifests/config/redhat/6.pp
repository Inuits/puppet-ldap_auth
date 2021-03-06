# == Class:  ldap_auth::config::redhat::6
#
# RedHat EL6 specific ldap_auth configuration.
#
# * Sets up the nslcd service.
# * Adjusts /etc/authconfig (using augeas).
# * Configures pam password-auth and system-auth.
#
class ldap_auth::config::redhat::6 {

  file{'/etc/nslcd.conf':
    owner   => 'root',
    group   => 'nslcd',
    mode    => '0640',
    content => template('ldap_auth/nslcd.conf.erb'),
    require => Package[$::ldap_auth::params::private_packages],
    notify  => Service[$::ldap_auth::params::private_nslcd_service],
  }

  service{$::ldap_auth::params::private_nslcd_service:
    ensure  => 'running',
    require => File['/etc/nslcd.conf'],
  }

  group{'nslcd':
    ensure => 'present',
    gid    => '7050',
  }

  augeas{'authconfig':
    context => '/files/etc/authconfig',
    changes => [
      'set /files/etc/sysconfig/authconfig/USELDAPAUTH yes',
      'set /files/etc/sysconfig/authconfig/USELDAP yes',
      'set /files/etc/sysconfig/authconfig/USEMKHOMEDIR yes',
    ]
  }


  ldap_auth::config::redhat::pam_config { ['password-auth', 'system-auth']: }

}
