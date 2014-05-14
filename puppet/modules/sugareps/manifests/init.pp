class sugareps {

  $php_package = params_lookup('php_package', 'global')
  $mysql_package_param = params_lookup('mysql_package', 'global')

  file { '/etc/motd':
    content => "SugarEPS: PHP 5.3.x, IBM DB2 10.5, Apache 2.4.x\n\n"
  }

  $mysql_package = $mysql_package_param ? {
    '' => false,
    default => $mysql_package_param
  }

  class { 'devops':
    php_package     => $php_package,
    mysql_package   => $mysql_package,
    deploy_environment => 'vagrantdb2'
  }

  class { 'devops::db::db2':
    require => [Devops::Apache['devops_apache'], Devops::Php['devops_php']]
  }

  php::pear::module { "Log":
    repository => 'pear.php.net',
    module_prefix => "${php_package}-",
    require => Package[$php_package]
  }
}