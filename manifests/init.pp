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

  vcsrepo { "/home/${user}/.vim":
    ensure => present,
    provider => git,
    source => 'https://github.com/a1russell/.vim.git',
    user => $user,
    require => Package['vim-gtk', 'git']
  }

  file { "/home/${user}/.vimrc":
    ensure => 'link',
    target => "/home/${user}/.vim/vimrc",
    owner => $user,
    group => $user,
    require => Vcsrepo["/home/${user}/.vim"]
  }

  exec { "install vim bundles":
    command => "vim '+BundleInstall' +qall &> /dev/null",
    path => '/usr/bin',
    user => $user,
    require => File["/home/${user}/.vimrc"]
  }

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

  package { 'scala':
    name => ['scala', 'scala-doc'],
    require => Java::Setup['java-7-oracle']
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

  exec { 'xfce-perchannel-xml directory':
    command => 'mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml',
    creates => "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml",
    cwd => "/home/${user}",
    path => '/bin',
    user => $user,
    require => Package['xfce4']
  }

  file { "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml":
    source => 'puppet:///modules/devenv/xfce4-power-manager.xml',
    owner => $user,
    group => $user,
    require => Exec['xfce-perchannel-xml directory']
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
    path => "/home/${user}/.config/xfce4/panel/launcher-9/xfce4-terminal.desktop",
    ensure => 'link',
    target => '/usr/share/applications/xfce4-terminal.desktop',
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
    path => "/home/${user}/.config/xfce4/panel/launcher-10/Thunar.desktop",
    ensure => 'link',
    target => '/usr/share/applications/Thunar.desktop',
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
    path => "/home/${user}/.config/xfce4/panel/launcher-11/google-chrome.desktop",
    ensure => 'link',
    target => '/usr/share/applications/google-chrome.desktop',
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

  file { 'gvim panel launcher directory':
    path => "/home/${user}/.config/xfce4/panel/launcher-16",
    ensure => 'directory',
    owner => $user,
    group => $user,
    require => Exec['panel config directory']
  }

  file { 'gvim panel launcher':
    path => "/home/${user}/.config/xfce4/panel/launcher-16/gvim.desktop",
    ensure => 'link',
    target => '/usr/share/applications/gvim.desktop',
    owner => $user,
    group => $user,
    require => File['terminal panel launcher directory']
  }

  file { "/home/${user}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml":
    source => 'puppet:///modules/devenv/xfce4-panel.xml',
    owner => $user,
    group => $user,
    require => [Exec['xfce-perchannel-xml directory'],
                File['terminal panel launcher',
                     'file manager panel launcher',
                     'web browser panel launcher',
                     'application finder panel launcher',
                     'idea panel launcher']]
  }
}
