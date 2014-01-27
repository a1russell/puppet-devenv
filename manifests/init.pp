class devenv ($user = 'vagrant') {
  include java7
  include apt
  Class['apt'] -> Package <| |>

  package { 'linux-headers-amd64': }

  package { 'lightdm': }

  file { '/etc/lightdm/lightdm.conf':
    content => template('devenv/lightdm.conf.erb'),
    require => Package['lightdm']
  }

  package { 'xfce4': }

  package { 'xfce4-goodies':
    require => Package['xfce4']
  }

  package { 'vim-gtk': }

  package { 'git': }

  class { 'googlechrome':
    require => Package['xfce4']
  }

  file { '/etc/profile.d/java.sh':
    source => 'puppet:///modules/devenv/java.sh',
    require => Class['java7']
  }

  class { 'idea::community':
    version => '13.0.2',
    build => '133.696',
    require => [Package['xfce4'],
                Class['java7']]
  }
}
