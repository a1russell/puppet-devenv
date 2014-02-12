class devenv::vim ($username) {
  package { 'vim-gtk': }

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
}
