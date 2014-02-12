class devenv::panel ($username) {
  exec { 'panel config directory':
    command => 'mkdir -p .config/xfce4/panel',
    creates => "/home/${username}/.config/xfce4/panel",
    cwd => "/home/${username}",
    path => '/bin',
    user => $username,
    require => Package['xfce4']
  }

  file { 'terminal panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-9",
    ensure => directory,
    owner => $username,
    group => $username,
    require => Exec['panel config directory']
  }

  file { 'terminal panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-9/xfce4-terminal.desktop",
    ensure => link,
    target => '/usr/share/applications/xfce4-terminal.desktop',
    owner => $username,
    group => $username,
    require => [File['terminal panel launcher directory'],
                Package['xfce4-goodies']]
  }

  file { 'file manager panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-10",
    ensure => directory,
    owner => $username,
    group => $username,
    require => Exec['panel config directory']
  }

  file { 'file manager panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-10/Thunar.desktop",
    ensure => link,
    target => '/usr/share/applications/Thunar.desktop',
    owner => $username,
    group => $username,
    require => File['file manager panel launcher directory']
  }

  file { 'web browser panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-11",
    ensure => directory,
    owner => $username,
    group => $username,
    require => Exec['panel config directory']
  }

  file { 'web browser panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-11/google-chrome.desktop",
    ensure => link,
    target => '/usr/share/applications/google-chrome.desktop',
    owner => $username,
    group => $username,
    require => [File['web browser panel launcher directory'],
                Class['googlechrome']]
  }

  file { 'application finder panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-12",
    ensure => directory,
    owner => $username,
    group => $username,
    require => Exec['panel config directory']
  }

  file { 'application finder panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-12/xfce4-appfinder.desktop",
    ensure => link,
    target => '/usr/share/applications/xfce4-appfinder.desktop',
    owner => $username,
    group => $username,
    require => File['application finder panel launcher directory']
  }

  file { 'idea panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-15",
    ensure => directory,
    owner => $username,
    group => $username,
    require => [File['idea shortcut'],
                Exec['panel config directory']]
  }

  file { 'idea panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-15/idea.desktop",
    ensure => link,
    target => "/home/${username}/.local/share/applications/idea.desktop",
    owner => $username,
    group => $username,
    require => File['idea panel launcher directory']
  }

  file { 'gvim panel launcher directory':
    path => "/home/${username}/.config/xfce4/panel/launcher-16",
    ensure => directory,
    owner => $username,
    group => $username,
    require => Exec['panel config directory']
  }

  file { 'gvim panel launcher':
    path => "/home/${username}/.config/xfce4/panel/launcher-16/gvim.desktop",
    ensure => link,
    target => '/usr/share/applications/gvim.desktop',
    owner => $username,
    group => $username,
    require => File['terminal panel launcher directory']
  }

  file { "/home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml":
    source => 'puppet:///modules/devenv/xfce4-panel.xml',
    owner => $username,
    group => $username,
    require => [Exec['xfce-perchannel-xml directory'],
                File['terminal panel launcher',
                     'file manager panel launcher',
                     'web browser panel launcher',
                     'application finder panel launcher',
                     'idea panel launcher']]
  }
}
