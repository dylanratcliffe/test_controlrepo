class profile::active {

  $rsync_user     = hiera('profile::active::rsync_user')
  $rsync_key      = hiera('profile::active::rsync_key')
  $rsync_key_name = hiera('profile::active::rsync_key_name')
  $rep_user       = hiera('profile::active::rep_user')
  $rep_key        = hiera('profile::active::rep_key')
  $rep_key_name   = hiera('profile::active::rep_key_name')

  $rsync_key_base = dirname($rsync_key_name)
  $rep_key_base   = dirname($rep_key_name)

  File {
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }

  file { $rsync_key_base:
    ensure => directory,
    owner  => $rsync_user,
    group  => $rsync_user,
  }

  file { $rsync_key_name:
    ensure  => file,
    owner   => $rsync_user,
    group   => $rsync_user,
    content => $rsync_key,
  }

  file { $rep_key_name:
    ensure  => file,
    owner   => $rep_user,
    group   => $rep_user,
    content => $rep_key,
  }

  Sshkey <<| tag == 'pe_ha' |>>

}
