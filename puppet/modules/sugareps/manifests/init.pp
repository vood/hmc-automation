class sugareps inherits devops::params {

  ## Lets Configure the PHP Variables
  $php_timezone             = params_lookup('php_timezone')
  $php_error_log            = params_lookup('php_error_log')
  $php_realpath_cache_size  = params_lookup('php_realpath_cache_size')
  $php_memory_limit         = params_lookup('php_memory_limit')
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
    java_install => true,
    config => {
    'cluster' => {
      'name' => 'batman',
      'discovery.zen.ping.multicast.enabled' => 'false'
      }
    }
  }

  package { [ 'zip', 'unzip', 'bind-utils' ]:
    ensure => 'installed'
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
}