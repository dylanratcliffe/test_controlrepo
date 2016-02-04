class profile::passive {

  $rsync_user         = hiera('profile::passive::rsync_user')
  $rsync_user_homedir = hiera('profile::passive::rsync_user_homedir',"/home/${rsync_user}")
  $rsync_user_pub     = hiera('profile::passive::rsync_user_pub')
  $rep_user           = hiera('profile::passive::rep_user')
  $rep_user_homedir   = hiera('profile::passive::rep_user_homedir',"/home/${rep_user}")
  $rep_user_pub       = hiera('profile::passive::rep_user_pub')

  include epel

  package { 'git':
    ensure => present,
  }

  file { "${rsync_user_homedir}/.ssh":
    ensure => directory,
    owner  => $rsync_user,
    group  => $rsync_user,
    mode   => '0700',
  }

  ssh_authorized_key { $rsync_user:
    ensure => present,
    user   => $rsync_user,
    key    => regsubst($rsync_user_pub, '\n$', ''),
    target => "${rsync_user_homedir}/.ssh/authorized_keys",
    type   => 'ssh-rsa',
  }

  ssh_authorized_key { $rep_user:
    ensure => present,
    user   => $rep_user,
    key    => regsubst($rep_user_pub, '\n$', ''),
    target => "${rep_user_homedir}/.ssh/authorized_keys",
    type   => 'ssh-rsa',
  }

  $non_loopback_interfaces = $::networking['interfaces'].filter |$int_name, $int_values| {
    ($int_name != 'lo') and
    ($int_values['ip'] != undef)
  }
  # Create an array of ip addresses for all non-loopback interfaces.
  $aliases = $non_loopback_interfaces.map |$int_name, $int_values| {
    $int_values['ip']
  }

  @@sshkey { $::fqdn:
    ensure       => present,
    host_aliases => $aliases,
    key          => $::ssh['rsa']['key'],
    type         => 'rsa',
    tag          => 'pe_ha',
  }
}
