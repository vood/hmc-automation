class sugareps inherits devops::params {

  ## Lets Configure the PHP Variables
  $php_timezone             = params_lookup('php_timezone')
  $php_error_log            = 'E_ALL'
  $php_realpath_cache_size  = params_lookup('php_realpath_cache_size')
  $php_memory_limit         = '1024'
  $php_max_input_time       = params_lookup('php_max_input_time')
  $php_max_input_vars       = params_lookup('php_max_input_vars')
  $php_max_execution_time   = params_lookup('php_max_execution_time')

  $php_apc_shm_size         = params_lookup('php_apc_shm_size')
  $php_apc_unit_size        = params_lookup('php_apc_unit_size')
  $php_apc_enabled          = params_lookup('php_apc_enabled')
  $php_apc_gc_ttl           = params_lookup('php_apc_gc_ttl')
  $php_apc_enable_cli       = params_lookup('php_apc_enable_cli')

  $php_xdebug_max_nexting_levels = params_lookup('php_xdebug_max_nexting_levels')

  $php_package              = 'php53u'
  $elastic_version          = '0.90.7'
  $mysql_package            = 'mysql'

  class { 'resolver':
    dns_servers => [ '10.8.1.30' ],
    search      => [ 'cup1.sugarcrm.net', 'sugarcrm.net', 'sugarcrm.pvt' ];
  }

  exec {'yum-clean-metadata':
    command => '/usr/bin/yum clean metadata',
    refreshonly => true
  }

  # Setup the Devops
  yum::managed_yumrepo { 'sugardevops':
    descr          => 'Sugar DevOps Rep',
    baseurl        => 'http://sugar-puppet.h2ik.co/repo/sugar-devops/el6/x86_64/',
    enabled        => 1,
    gpgcheck       => 0,
    priority       => 1,
    before         => [Class['apache'], Class['php']],
    require        => [Class['resolver']],
    notify         => [Exec['yum-clean-metadata']];
  }

  class {'devops::known_hosts' :
    before => [Class['git']],
    require => [Package['bind-utils']];
  }

  # Lets Install Apache
  devops::apache { 'devops_apache' :
  }

  # Lets Install PHP
  devops::php { 'devops_php' :
    php_package => $php_package;
  }

  # Install Elastic Search
  class { 'elasticsearch':
    version => $elastic_version,
#    java_install => true,
#    config => {
#    'cluster' => {
#      'name' => 'batman',
#      'discovery.zen.ping.multicast.enabled' => 'false'
#      }
#    }
  }

  package { [ 'zip', 'unzip', 'bind-utils', 'ruby-devel' ]:
    ensure => 'installed',
    before => Package['jsduck']
  }

  file { '/etc/motd':
    content => "SugarEPS: PHP 5.3.x, IBM DB2 10.5, Apache 2.4.x\n\n"
  }

  # Lets Install MySQL
  # Get the MySQL Params
  $mysql_user = params_lookup('mysql_username')
  $mysql_pass = params_lookup('mysql_password')
  $mysql_db   = params_lookup('mysql_database')
  devops::mysql { 'devops_mysql':
    mysql_package => $mysql_package,
    mysql_user => $mysql_user,
    mysql_pass=> $mysql_pass,
    mysql_db => $mysql_db;
  }

  class { 'db2': }

  #NodeJs and packages
  include nodejs

  package { ['uglifyjs', 'jshint']:
    ensure   => 'installed',
    provider => 'npm',
  }

  #Ruby gems
  package { 'jsduck':
    ensure   => 'installed',
    provider => 'gem',
  }

  exec {'/usr/bin/wget http://pecl.php.net/get/ibm_db2 -O /tmp/ibm_db2.tar.gz':
    command => '/usr/bin/wget http://pecl.php.net/get/ibm_db2 -O /tmp/ibm_db2.tar.gz',
    creates => '/tmp/ibm_db2.tar.gz',
    require => Class['db2']
  }->
  exec {'/bin/tar zxf /tmp/ibm_db2.tar.gz -C /tmp':
    command => '/bin/tar zxf /tmp/ibm_db2.tar.gz -C /tmp',
    creates => '/tmp/ibm_db2-1.9.5'
  }->
  exec { 'cd /tmp/ibm_db2-1.9.5 && phpize --clean && phpize && ./configure --with-IBM_DB2=/opt/ibm/db2/V10.5 && make && make install':
    command => 'cd /tmp/ibm_db2-1.9.5 && phpize --clean && phpize && ./configure --with-IBM_DB2=/opt/ibm/db2/V10.5 && make && make install',
  }

  file { '/etc/php.d/ibm_db2.ini':
    content => 'extension=ibm_db2.so'
  }
}