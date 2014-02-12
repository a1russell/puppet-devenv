class devenv::chrome ($username) {
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
}
