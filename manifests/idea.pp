class devenv::idea ($username, $version, $build) {
  class { 'idea::community':
    version => $version,
    build => $build,
    timeout => 2700,
    require => [Package['xfce4'],
                Class['java7']]
  }

  file { '/etc/profile.d/idea.sh':
    source => 'puppet:///modules/devenv/idea.sh',
    require => Class['idea::community', 'java7']
  }

  file { 'idea shortcut':
    path => "/home/${username}/.local/share/applications/idea.desktop",
    owner => $username,
    group => $username,
    source => 'puppet:///modules/devenv/idea.desktop',
    require => [Class['idea::community'],
                Exec['user applications directory']]
  }

  file { "/home/${username}/IdeaProjects":
    ensure => link,
    target => "/home/${username}/proj",
    owner => $username,
    group => $username,
    require => File["/home/${username}/proj"]
  }
}
