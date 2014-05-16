class aix {
  $ibm_mirror = "http://10.8.7.188/sfadriver.rchland.ibm.com/sugarkit/"
  $tmp = '/tmp/ibm'
  $tag_target = 'r20'

  package { "bash":
    source => "ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/bash/bash-4.2-1.aix6.1.ppc.rpm",
    provider => "rpm",
    ensure => "installed"
  }

  package { "vim-minimal":
    source => "ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/vim/vim-minimal-6.3-1.aix5.1.ppc.rpm",
    provider => "rpm",
    ensure => "installed"
  }

  package { "vim-common":
    source => "ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/vim/vim-common-6.3-1.aix5.1.ppc.rpm",
    provider => "rpm",
    ensure => "installed"
  }

  package { "vim-enhanced":
    source => "ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/vim/vim-enhanced-6.3-1.aix5.1.ppc.rpm",
    provider => "rpm",
    ensure => "installed"
  }

  file { $tmp:
    path => $tmp,
    ensure => "directory"
  }->

  exec { "base_71.tar":
    path => "/usr/bin:/usr/sbin",
    command => "wget $ibm_mirror/base_71.tar -O $tmp/base_71.tar",
    creates => "$tmp/base_71.tar",
  }->

  exec { "r20_base.tar":
    path => "/usr/bin:/usr/sbin",
    command => "wget $ibm_mirror/r20_base.tar -O $tmp/r20_base.tar",
    creates => "$tmp/r20_base.tar"
  }->

  exec { "r20_linux_compat.tar":
    path => "/usr/bin:/usr/sbin",
    command => "wget $ibm_mirror/r20_linux_compat.tar -O $tmp/r20_linux_compat.tar",
    creates => "$tmp/r20_linux_compat.tar"
  }->

  exec { "r20_middleware.tar":
    path => "/usr/bin:/usr/sbin",
    command => "wget $ibm_mirror/r20_middleware.tar -O $tmp/r20_middleware.tar",
    creates => "$tmp/r20_middleware.tar"
  }->

  exec { "base_71":
    cwd     => $tmp,
    path => "/usr/bin:/usr/sbin",
    command => "tar -xf $tmp/base_71.tar",
    creates => "$tmp/base_71",
  }->

  exec { "r20_base":
    cwd     => $tmp,
    path => "/usr/bin:/usr/sbin",
    command => "tar -xf $tmp/r20_base.tar",
    creates => "$tmp/r20_base",
  }->

  exec { "r20_linux_compat":
    cwd     => $tmp,
    path => "/usr/bin:/usr/sbin",
    command => "tar -xf $tmp/r20_linux_compat.tar",
    creates => "$tmp/r20_linux_compat",
  }->

  exec { "r20_middleware":
    cwd     => $tmp,
    path => "/usr/bin:/usr/sbin",
    command => "tar -xf $tmp/r20_middleware.tar",
    creates => "$tmp/r20_middleware",
  }->

  exec { "packages from base_71":
    command => "$rpm -Uvh --force --nodeps $tmp/base_71/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_base":
    path => "/usr/bin:/usr/sbin",
    command => "rpm -Uvh --force --nodeps $tmp/r20_base/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_linux_compat":
    path => "/usr/bin:/usr/sbin",
    command => "rpm -Uvh --force --nodeps $tmp/r20_linux_compat/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_middleware":
    path => "/usr/bin:/usr/sbin",
    command => "rpm -Uvh --force --nodeps $tmp/r20_middleware/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }

  file { "$tmp/git":
    path => "$tmp/git",
    ensure => "directory"
  }->
  exec { "git deps":
    path => "/usr/bin:/usr/sbin",
    command => "wget ftp://www.oss4aix.org/rpmdb/deplists/aix71/git-1.8.5.4-1.aix5.1.ppc.deps -O $tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps",
    creates => "$tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps"
  }->
  exec { "git dep rpms":
    path => "/usr/bin:/usr/sbin",
    command => "wget -P $tmp/git -B ftp://www.oss4aix.org/everything/RPMS/ -i $tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps",
    creates => "$tmp/git/zlib-1.2.3-4.aix5.2.ppc.rpm",
    timeout => 1800
  }->
  exec { "git rpm":
    path => "/usr/bin:/usr/sbin",
    command => "wget http://www.oss4aix.org/download/RPMS/git/git-1.8.5.4-1.aix5.1.ppc.rpm -O $tmp/git/git-1.8.5.4-1.aix5.1.ppc.rpm",
    creates => "$tmp/git/git-1.8.5.4-1.aix5.1.ppc.rpm",
  }->
  exec { "install all git packages":
    path => "/usr/bin:/usr/sbin",
    command => "rpm -Uvh --force --nodeps $tmp/git/*.rpm",
    creates => '/usr/bin/git',
    timeout => 1800
  }->
  exec { "chfs":
    path => "/usr/bin:/usr/sbin",
    command => "chfs -a size=20G /"
  }->
  exec { "crfs":
    path => "/usr/bin:/usr/sbin",
    command => "crfs -m /ramdisk0 -a size=16G -g rootvg -v jfs2 -a mount=true -A on",
    creates => "/ramdisk0"
  }->
  exec { "unmount ramdisk0":
    path => "/usr/bin:/usr/sbin",
    command => "unmount /ramdisk0",
    onlyif => "mount | grep ramdisk0 | grep log=/dev/hd8"
  }->
  exec { "mount ramdisk0":
    path => "/usr/bin:/usr/sbin",
    command => "mount -o log=NULL /ramdisk0",
    unless => "mount | grep ramdisk0"
  }->
  file { '/var/www/htdocs/build_folder':
    ensure => 'link',
    target => '/ramdisk0',
  }->
  file { "/srv":
    ensure => "directory"
  }->
  file { "/home/puppet/.ssh":
    ensure => 'directory',
    mode    => 0600,
    owner   => 'puppet'
  }->
  file { "/home/puppet/.ssh/id_rsa":
    source => ("puppet:///modules/aix/id_rsa"),
    mode    => 0600,
    owner   => 'puppet'
  }->
  file { "/.ssh":
    ensure => 'directory',
    mode    => 0600,
    owner   => 'root'
  }->
  file { "/.ssh/id_rsa":
    source => ("puppet:///modules/aix/id_rsa"),
    mode    => 0600,
    owner   => 'root'
  }->
  exec { "git clone git@github.com:sugarcrm/AutoUtils.git":
    path => "/usr/bin:/usr/sbin",
    command => "git clone git@github.com:sugarcrm/AutoUtils.git /srv/AutoUtils",
    creates => "/srv/AutoUtils"
  }->
  exec { "cpan YAML":
    path => "/usr/bin:/usr/sbin",
    command => "cpan YAML"
  }

  $memory_limit = '2048M'
  $error_reporting = 'E_ALL'

  file {"/opt/freeware/etc/php.ini":
    content => template('aix/php.ini.erb'),
    owner   => 'root',
    mode    => 0644,
    require => File['/opt/freeware/bin/php'],
    ensure => 'present',
    notify  => Exec['/opt/freeware/sbin/httpd -k restart'],
  }

  file {"/opt/freeware/etc/php.d/apc.ini":
    source => "puppet:///modules/aix/apc.ini",
    owner   => 'root',
    mode    => 0644,
    require => File['/opt/freeware/bin/php'],
    ensure => 'present',
    notify  => Exec['httpd -k restart'],
  }

  exec { 'httpd -k restart':
    path => "/opt/freeware/sbin",
    command => 'httpd -k restart'
  }

  file { '/opt/freeware/bin/php':
    name => '/opt/freeware/bin/php',
    ensure => 'present'
  }

  file { '/opt/freeware/sbin/httpd':
    name => '/opt/freeware/sbin/httpd',
    ensure => 'present'
  }

  file { "/etc/resolv.conf":
    source => "puppet:///modules/aix/resolv.conf",
  }

  exec { "change db2 port to 50000":
    command => "/usr/bin/sed 's/50001/50000/g' /etc/services > /tmp/service.tmp; mv /tmp/service.tmp /etc/services",
    unless => '/usr/bin/grep "db2c_db2inst1 50000/tcp" /etc/services'
  }

  file { "/opt/freeware/etc/httpd/conf/extra/server-tuning.conf":
    source => "puppet:///modules/aix/server-tuning.conf",
    require => File['/opt/freeware/sbin/httpd'],
    owner   => 'root',
    mode    => 0644,
    ensure => 'present',
  }->
  file { "/opt/freeware/etc/httpd/conf/httpd.conf":
    content => template('aix/httpd.conf.erb'),
    owner   => 'root',
    mode    => 0644,
    require => File['/opt/freeware/sbin/httpd'],
    ensure => 'present',
    notify  => Exec['/opt/freeware/sbin/httpd -k restart']
  }

  file { "/Automation":
    ensure => "directory"
  }

  file { "/home/db2inst1/sqllib/db2nodes.cfg":
    content => inline_template("0 ${hostname} 0\n")
  }

  file { "/etc/environment":
    source => "puppet:///modules/aix/environment",
  }

  file { "/home/db2inst1/sqllib/profile.env":
    source => "puppet:///modules/aix/profile.env",
    owner => 'db2inst1',
    ensure => 'present'
  }

  exec { "/usr/sbin/chps -s 39 hd6":
    path => "/usr/bin:/usr/sbin",
    command => "chps -s 39 hd6",
    unless => "lsps -a | grep hd6 | grep 5504MB"
  }

  file { "/etc/security/limits":
    content => "puppet:///modules/aix/limits",
    owner => 'root',
    ensure => 'present'
  }
}