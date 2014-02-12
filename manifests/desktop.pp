class devenv::desktop ($username) {
  package { 'lightdm': }

  file { '/etc/lightdm/lightdm.conf':
    content => template('devenv/lightdm.conf.erb'),
    require => Package['lightdm']
  }

  package { 'xfce4': }

  package { 'xfce4-goodies':
    require => Package['xfce4']
  }

  file { '/etc/X11/Xsession.d/0profile':
    source => 'puppet:///modules/devenv/0profile',
    require => Package['xfce4']
  }

  exec { 'echo "mode: off" > .xscreensaver':
    creates => "/home/${username}/.xscreensaver",
    cwd => "/home/${username}",
    path => '/bin',
    user => $username
  }

  exec { 'user applications directory':
    command => 'mkdir -p .local/share/applications',
    creates => "/home/${username}/.local/share/applications",
    cwd => "/home/${username}",
    path => '/bin',
    user => $username
  }

  exec { 'xfce-perchannel-xml directory':
    command => 'mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml',
    creates => "/home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml",
    cwd => "/home/${username}",
    path => '/bin',
    user => $username,
    require => Package['xfce4']
  }

  file { "/home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml":
    source => 'puppet:///modules/devenv/xfce4-power-manager.xml',
    owner => $username,
    group => $username,
    require => Exec['xfce-perchannel-xml directory']
  }
}
