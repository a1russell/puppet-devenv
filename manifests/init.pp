class devenv ($user = 'vagrant') {
  include java7
  include apt

  Class['apt'] -> Package <| |>

  package { 'linux-headers-amd64': }

  package { 'augeas':
    name => ['augeas-tools', 'augeas-lenses', 'libaugeas-ruby']
  }

  Package['augeas'] -> Augeas <| |>

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
    creates => "/home/${user}/.xscreensaver",
    cwd => "/home/${user}",
    path => '/bin',
    user => $user
  }

  package { 'vim-gtk': }

  package { 'git': }

  class { 'googlechrome':
    require => Package['xfce4']
  }

  exec { 'update-alternatives --set x-www-browser \
          /usr/bin/google-chrome-stable':
    path => '/usr/bin:/bin',
    unless => 'update-alternatives --query x-www-browser |\
               grep Value | grep -q google-chrome-stable',
    require => Class['googlechrome']
  }

  exec { "echo 'x-scheme-handler/http=exo-web-browser.desktop' >>\
          /home/${user}/.local/share/applications/mimeapps.list":
    path => '/bin',
    unless => "grep -q 'x-scheme-handler/http\s*=' \
               /home/${user}/.local/share/applications/mimeapps.list",
    require => Class['googlechrome']
  }

  exec { "echo 'x-scheme-handler/https=exo-web-browser.desktop' >>\
          /home/${user}/.local/share/applications/mimeapps.list":
    path => '/bin',
    unless => "grep -q 'x-scheme-handler/https\s*=' \
               /home/${user}/.local/share/applications/mimeapps.list",
    require => Class['googlechrome']
  }

  augeas { 'set xfce default browser':
    lens => 'Shellvars.lns',
    incl => "/home/${user}/.config/xfce4/helpers.rc",
    changes => [
      'set WebBrowser google-chrome'
    ],
    require => Class['googlechrome']
  }

  file { '/etc/profile.d/java.sh':
    source => 'puppet:///modules/devenv/java.sh',
    require => Class['java7']
  }

  class { 'gradle':
    version => '1.10',
    require => Class['java7']
  }

  class { 'idea::community':
    version => '13.0.2',
    build => '133.696',
    require => [Package['xfce4'],
                Class['java7']]
  }

  exec { 'user applications directory':
    command => 'mkdir -p .local/share/applications',
    creates => "/home/${user}/.local/share/applications",
    cwd => "/home/${user}",
    path => '/bin',
    user => $user
  }

  exec { 'panel config directory':
    command => 'mkdir -p .config/xfce4/panel',
    creates => "/home/${user}/.config/xfce4/panel",
    cwd => "/home/${user}",
    path => '/bin',
    user => $user,
    require => Package['xfce4']
  }

  file { 'terminal panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-9",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => Exec['panel config directory']
  }

  file { 'terminal panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-9/exo-terminal-emulator.desktop",
    ensure => 'link',
    target => '/usr/share/applications/exo-terminal-emulator.desktop',
    owner => $user,
    group => $user,
    require => File['terminal panel launcher directory']
  }

  file { 'file manager panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-10",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => Exec['panel config directory']
  }

  file { 'file manager panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-10/exo-file-manager.desktop",
    ensure => 'link',
    target => '/usr/share/applications/exo-file-manager.desktop',
    owner => $user,
    group => $user,
    require => File['file manager panel launcher directory']
  }

  file { 'web browser panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-11",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => Exec['panel config directory']
  }

  file { 'web browser panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-11/exo-web-browser.desktop",
    ensure => 'link',
    target => '/usr/share/applications/exo-web-browser.desktop',
    owner => $user,
    group => $user,
    require => File['web browser panel launcher directory']
  }

  file { 'application finder panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-12",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => Exec['panel config directory']
  }

  file { 'application finder panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-12/xfce4-appfinder.desktop",
    ensure => 'link',
    target => '/usr/share/applications/xfce4-appfinder.desktop',
    owner => $user,
    group => $user,
    require => File['application finder panel launcher directory']
  }

  exec { 'xfce-perchannel-xml directory':
    command => 'mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml',
    creates => "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml",
    cwd => "/home/${user}",
    path => '/bin',
    user => $user,
    require => Package['xfce4']
  }

  file { "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml":
    source => 'puppet:///modules/devenv/xfce4-panel.xml',
    owner => $user,
    group => $user,
    replace => false,
    require => [Exec['xfce-perchannel-xml directory'],
                File['terminal panel launcher',
                     'file manager panel launcher',
                     'web browser panel launcher',
                     'application finder panel launcher']]
  }

  file { "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml":
    source => 'puppet:///modules/devenv/xfce4-power-manager.xml',
    owner => $user,
    group => $user,
    require => Exec['xfce-perchannel-xml directory']
  }

  file { 'idea shortcut':
    path => "/home/${user}/.local/share/applications/idea.desktop",
    owner => $user,
    group => $user,
    source => 'puppet:///modules/devenv/idea.desktop',
    require => [Class['idea::community'],
                Exec['user applications directory']]
  }

  file { 'idea panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-15",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => [File['idea shortcut'],
                Exec['panel config directory']]
  }

  file { 'idea panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-15/idea.desktop",
    ensure => 'link',
    target => "/home/${user}/.local/share/applications/idea.desktop",
    owner => $user,
    group => $user,
    require => File['idea panel launcher directory']
  }

  augeas { 'add idea launcher to panel':
    lens => 'Xml.lns',
    incl => "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
    changes => [
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/#attribute/name plugin-15',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/#attribute/type string',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/#attribute/value launcher',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/property[#attribute/name="items"]/#attribute/name items',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/property[#attribute/name="items"]/#attribute/type array',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/property[#attribute/name="items"]/value/#attribute/type string',
      'set channel/property[#attribute/name="plugins"]/property[#attribute/name="plugin-15"]/property[#attribute/name="items"]/value/#attribute/value idea.desktop',
    ],
    require => File['idea panel launcher',
                    "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"]
  }

  augeas { 'order idea launcher in panel':
    lens => 'Xml.lns',
    incl => "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
    changes => [
      'defvar panels channel/property[#attribute/name="panels"]',
      'defvar panel1 $panels/property[#attribute/name="panel-1"]',
      'defvar pluginids $panel1/property[#attribute/name="plugin-ids"]',
      'ins value after $pluginids/value[#attribute/value="9"]',
      'set $pluginids/value[count(#attribute) = 0]/#attribute/value 15',
      'set $pluginids/value[#attribute/value="15"]/#attribute/type int',
    ],
    onlyif => 'match channel/property[#attribute/name="panels"]/property[#attribute/name="panel-1"]/property[#attribute/name="plugin-ids"]/value[#attribute/value="15"] size == 0',
    require => File['idea panel launcher',
                    "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"]
  }
}
