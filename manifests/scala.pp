class devenv::scala ($username, $version) {
  archive { 'scala':
    ensure => present,
    checksum => false,
    url => "http://www.scala-lang.org/files/archive/scala-${version}.tgz",
    target => '/opt',
    require => Class['java7']
  }

  file { '/opt/scala':
    ensure => link,
    target => "/opt/scala-${version}",
    require => Archive['scala']
  }

  file { '/etc/profile.d/scala.sh':
    source => 'puppet:///modules/devenv/scala.sh',
    require => File['/opt/scala']
  }

  file { "/opt/scala-${version}/doc/scala-devel-docs":
    ensure => directory,
    require => Archive['scala']
  }

  archive { 'scala-docs':
    ensure => present,
    checksum => false,
    url => "http://www.scala-lang.org/files/archive/scala-docs-${version}.txz",
    extension => 'txz',
    target => "/opt/scala-${version}/doc/scala-devel-docs",
    require => File["/opt/scala-${version}/doc/scala-devel-docs"]
  }

  file { "/opt/scala-${version}/doc/scala-devel-docs/api":
    ensure => link,
    target => "/opt/scala-${version}/doc/scala-devel-docs/scala-docs-${version}",
    require => Archive['scala-docs']
  }

  file { '/var/tmp/conscript_setup.sh':
    source => 'puppet:///modules/devenv/conscript_setup.sh',
    require => Archive['scala']
  }

  exec { 'conscript setup':
    command => 'sh /var/tmp/conscript_setup.sh',
    creates => "/home/${username}/bin/cs",
    path => ['/usr/bin', '/bin'],
    environment => "HOME=/home/${username}",
    user => $username,
    require => File['/var/tmp/conscript_setup.sh']
  }

  exec { 'cs n8han/giter8':
    creates => "/home/${username}/bin/g8",
    path => ["/home/${username}/bin", '/usr/lib/jvm/java-7-oracle/bin'],
    timeout => 420,
    user => $username,
    require => Exec['conscript setup']
  }
}
