class devenv ($username = 'vagrant') {
  $idea_version = '13.0.2'
  $idea_build = '133.696'
  $gradle_version = '1.10'
  $scala_version = '2.10.3'

  include apt

  Class['apt'] -> Package <| |>

  Package['augeas'] -> Augeas <| |>

  package { 'linux-headers-amd64': }

  package { 'augeas':
    name => ['augeas-tools', 'augeas-lenses', 'libaugeas-ruby']
  }

  package { 'git': }

  class { 'devenv::desktop':
    username => $username
  }

  class { 'devenv::panel':
    username => $username
  }

  rbenv::install { $username:
    rc => '.bashrc'
  }

  class { 'devenv::java': }

  class { 'devenv::scala':
    username => $username,
    version => $scala_version
  }

  class { 'gradle':
    version => $gradle_version,
    require => Class['java7']
  }

  class { 'devenv::vim':
    username => $username
  }

  class { 'devenv::chrome':
    username => $username
  }

  class { 'devenv::idea':
    username => $username,
    version => $idea_version,
    build => $idea_build
  }
}
