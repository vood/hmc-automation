class sugareps {

  file { '/etc/motd':
    content => "SugarEPS: PHP 5.3.x, IBM DB2 10.5, Apache 2.4.x\n\n"
  }

  $mysql_package_param = params_lookup('mysql_package', 'global')
  $mysql_package = $mysql_package_param ? {
    '' => false,
    default => $mysql_package_param
  }

  class { 'devops':
    php_package     => 'php53u',
    mysql_package   => $mysql_package,
    deploy_environment => 'vagrantdb2'
  }

  # since we are not installing mysql and this is the db2 box, we should install db2, but we need to make sure that
  # the apache and php are installed first class is installed first
  class { 'devops::db::db2':
    require => [Devops::Apache['devops_apache'], Devops::Php['devops_php']]
  }

  php::pear::module { "Log": }
}