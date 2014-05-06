class sugareps {

  group { 'puppet':
    ensure => 'present',
  }

  file { '/etc/motd':
    content => "SugarEPS: PHP 5.3.x, IBM DB2 10.5, Apache 2.4.x\n\n"
  }

  class { 'devops':
    php_package     => 'php53u',
    mysql_package   => 'mysql55',
  }

  class { 'db2': }

  class { 'elasticsearch':
    version => '0.90.7-1',
      java_install => true,
      config => {
      'cluster' => {
      'name' => 'batman',
      'discovery.zen.ping.multicast.enabled' => 'false'
      }
    }
  }
}