class devenv ($username = 'vagrant') {
  $idea_version = '13.0.2'
  $idea_build = '133.696'
  $gradle_version = '1.10'
  $scala_version = '2.10.3'

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
    creates => "/home/${username}/.xscreensaver",
    cwd => "/home/${username}",
    path => '/bin',
    user => $username
  }

  package { 'vim-gtk': }

  package { 'git': }

  vcsrepo { "/home/${username}/.vim":
    ensure => present,
    provider => git,
    source => 'https://github.com/a1russell/.vim.git',
    user => $username,
    require => Package['vim-gtk', 'git']
  }

  file { "/home/${username}/.vimrc":
    ensure => link,
    target => "/home/${username}/.vim/vimrc",
    owner => $username,
    group => $username,
    require => Vcsrepo["/home/${username}/.vim"]
  }

  exec { "install vim bundles":
    command => "vim '+BundleInstall' +qall &> /dev/null",
    path => '/usr/bin',
    user => $username,
    require => File["/home/${username}/.vimrc"]
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
          /home/${username}/.local/share/applications/mimeapps.list":
    path => '/bin',
    unless => "grep -q 'x-scheme-handler/http\s*=' \
               /home/${username}/.local/share/applications/mimeapps.list",
    require => Class['googlechrome']
  }

  exec { "echo 'x-scheme-handler/https=exo-web-browser.desktop' >>\
          /home/${username}/.local/share/applications/mimeapps.list":
    path => '/bin',
    unless => "grep -q 'x-scheme-handler/https\s*=' \
               /home/${username}/.local/share/applications/mimeapps.list",
    require => Class['googlechrome']
  }

  augeas { 'set xfce default browser':
    lens => 'Shellvars.lns',
    incl => "/home/${username}/.config/xfce4/helpers.rc",
    changes => [
      'set WebBrowser google-chrome'
    ],
    require => Class['googlechrome']
  }

  rbenv::install { $username: }

  file { '/etc/profile.d/java.sh':
    source => 'puppet:///modules/devenv/java.sh',
    require => Class['java7']
  }

  class { 'gradle':
    version => $gradle_version,
    require => Class['java7']
  }

  archive { 'scala':
    ensure => present,
    checksum => false,
    url => "http://www.scala-lang.org/files/archive/scala-${scala_version}.tgz",
    target => '/opt'
  }

  file { '/opt/scala':
    ensure => link,
    target => "/opt/scala-${scala_version}",
    require => Archive['scala']
  }

  file { '/etc/profile.d/scala.sh':
    source => 'puppet:///modules/devenv/scala.sh',
    require => File['/opt/scala']
  }

  file { '/opt/scala/doc/scala-devel-docs':
    ensure => directory,
    require => [Archive['scala'],
                File['/opt/scala']]
  }

  archive { 'scala-docs':
    ensure => present,
    checksum => false,
    url => "http://www.scala-lang.org/files/archive/scala-docs-${scala_version}.txz",
    extension => 'txz',
    target => '/opt/scala/doc/scala-devel-docs',
    require => File['/opt/scala/doc/scala-devel-docs']
  }

  file { '/opt/scala/doc/scala-devel-docs/api':
    ensure => link,
    target => "/opt/scala/doc/scala-devel-docs/scala-docs-${scala_version}",
    require => Archive['scala-docs']
  }

  class { 'idea::community':
    version => $idea_version,
    build => $idea_build,
    require => [Package['xfce4'],
                Class['java7']]
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

  file { 'idea shortcut':
    path => "/home/${username}/.local/share/applications/idea.desktop",
    owner => $username,
    group => $username,
    source => 'puppet:///modules/devenv/idea.desktop',
    require => [Class['idea::community'],
                Exec['user applications directory']]
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
