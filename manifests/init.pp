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

  file { "/home/${user}/.config/xfce4/helpers.rc":
    owner => $user,
    group => $user,
    source => 'puppet:///modules/devenv/helpers.rc',
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
}
