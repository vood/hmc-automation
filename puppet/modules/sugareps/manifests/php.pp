define sugareps::php (
  $php_package
  ) {

  # Lets Install PHP
  class { 'php':
    package => "${php_package}",
    template => 'sugareps/php.ini.erb',
  }

  php::module { 'cli':
    module_prefix => "${php_package}-"
  }
  php::module { 'devel':
    module_prefix => "${php_package}-"
  }
  php::module { 'mbstring':
    module_prefix => "${php_package}-"
  }
  php::module { 'pear':
    module_prefix => "${php_package}-"
  }
  php::module { 'common':
    module_prefix => "${php_package}-"
  }
  php::module { 'xml':
    module_prefix => "${php_package}-"
  }
  php::module { 'ldap':
    module_prefix => "${php_package}-"
  }
  php::module { 'gd':
    module_prefix => "${php_package}-"
  }
  php::module { 'mcrypt':
    module_prefix => "${php_package}-"
  }
  php::module { 'imap':
    module_prefix => "${php_package}-"
  }
  php::module { 'soap':
    module_prefix => "${php_package}-"
  }
  php::module { 'process':
    module_prefix => "${php_package}-"
  }
  php::module { 'bcmath':
    module_prefix => "${php_package}-"
  }
  php::module { 'pecl-jsmin':
    module_prefix => "${php_package}-"
  }
  php::module { 'pecl-memcache':
    module_prefix => "${php_package}-"
  }
  php::module { 'pecl-xdebug':
    module_prefix => "${php_package}-"
  }
  file {'/etc/php.d/xdebug.ini':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('devops/xdebug.ini.erb'),
    require => Package["${php_package}-pecl-xdebug"]
  }

  php::module { 'pecl-xhprof':
    module_prefix => "${php_package}-"
  }

  # APC is built into PHP55
  if ($php_package != 'php55u') {
    php::module { 'pecl-apc':
      module_prefix => "${php_package}-"
    }

    file {'/etc/php.d/apc.ini':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('devops/apc.ini.erb'),
        require => Package["${php_package}-pecl-apc"]
    }

    php::module { 'mysql':
      module_prefix => "${php_package}-",
      require => Class['mysql']
    }
  } else {
    php::module { 'mysqlnd':
      module_prefix => "${php_package}-",
      require => Class['mysql']
    }
  }

  devops::php::phpunit { 'devops-phpunit':
    php_package => $php_package
  }

  devops::php::composer { 'devops-composer':
    php_package => $php_package
  }

  file {
    "/var/www/html/info.php":
    owner   => 'vagrant',
    group   => 'apache',
    mode    => '0644',
    require => Class['apache'],
    content => '<?php phpinfo(); ?>'
  }
}