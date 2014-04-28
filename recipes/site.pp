class aix {
  $ibm_mirror = "http://10.8.7.188/sfadriver.rchland.ibm.com/sugarkit/"
  $tmp = '/tmp/ibm'
  $rpm = "/usr/bin/rpm"
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
    command => "/usr/bin/wget $ibm_mirror/base_71.tar -O $tmp/base_71.tar",
    creates => "$tmp/base_71.tar",
  }->

  exec { "r20_base.tar":
    command => "/usr/bin/wget $ibm_mirror/r20_base.tar -O $tmp/r20_base.tar",
    creates => "$tmp/r20_base.tar"
  }->

  exec { "r20_linux_compat.tar":
    command => "/usr/bin/wget $ibm_mirror/r20_linux_compat.tar -O $tmp/r20_linux_compat.tar",
    creates => "$tmp/r20_linux_compat.tar"
  }->

  exec { "r20_middleware.tar":
    command => "/usr/bin/wget $ibm_mirror/r20_middleware.tar -O $tmp/r20_middleware.tar",
    creates => "$tmp/r20_middleware.tar"
  }->

  exec { "base_71":
    cwd     => $tmp,
    command => "/usr/bin/tar -xf $tmp/base_71.tar",
    creates => "$tmp/base_71",
  }->

  exec { "r20_base":
    cwd     => $tmp,
    command => "/usr/bin/tar -xf $tmp/r20_base.tar",
    creates => "$tmp/r20_base",
  }->

  exec { "r20_linux_compat":
    cwd     => $tmp,
    command => "/usr/bin/tar -xf $tmp/r20_linux_compat.tar",
    creates => "$tmp/r20_linux_compat",
  }->

  exec { "r20_middleware":
    cwd     => $tmp,
    command => "/usr/bin/tar -xf $tmp/r20_middleware.tar",
    creates => "$tmp/r20_middleware",
  }->

  exec { "packages from base_71":
    command => "$rpm -Uvh --force --nodeps $tmp/base_71/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_base":
    command => "$rpm -Uvh --force --nodeps $tmp/r20_base/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_linux_compat":
    command => "$rpm -Uvh --force --nodeps $tmp/r20_linux_compat/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }->

  exec { "packages from r20_middleware":
    command => "$rpm -Uvh --force --nodeps $tmp/r20_middleware/*.rpm",
    creates => '/opt/freeware/etc/httpd/conf/httpd.conf',
    timeout => 1800
  }

  file { "$tmp/git":
    path => "$tmp/git",
    ensure => "directory"
  }->
  exec { "git deps":
    command => "/usr/bin/wget ftp://www.oss4aix.org/rpmdb/deplists/aix71/git-1.8.5.4-1.aix5.1.ppc.deps -O $tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps",
    creates => "$tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps"
  }->
  exec { "git dep rpms":
    command => "/usr/bin/wget -P $tmp/git -B ftp://www.oss4aix.org/everything/RPMS/ -i $tmp/git/git-1.8.5.4-1.aix5.1.ppc.deps",
    creates => "$tmp/git/zlib-1.2.3-4.aix5.2.ppc.rpm",
    timeout => 1800
  }->
  exec { "git rpm":
    command => "/usr/bin/wget http://www.oss4aix.org/download/RPMS/git/git-1.8.5.4-1.aix5.1.ppc.rpm -O $tmp/git/git-1.8.5.4-1.aix5.1.ppc.rpm",
    creates => "$tmp/git/git-1.8.5.4-1.aix5.1.ppc.rpm",
  }->
  exec { "install all git packages":
    command => "$rpm -Uvh --force --nodeps $tmp/git/*.rpm",
    creates => '/usr/bin/git',
    timeout => 1800
  }->
  exec { "chfs":
    command => "/usr/sbin/chfs -a size=20G /"
  }->
  exec { "crfs":
    command => "/usr/sbin/crfs -m /ramdisk0 -a size=16G -g rootvg -v jfs2 -a mount=true",
    creates => "/ramdisk0"
  }->
  exec { "unmount ramdisk0":
    command => "/usr/sbin/unmount /ramdisk0",
    onlyif => "/usr/sbin/mount | /usr/bin/grep ramdisk0 | /usr/bin/grep log=/dev/hd8"
  }->
  exec { "mount ramdisk0":
    command => "/usr/sbin/mount -o log=NULL /ramdisk0",
    unless => "/usr/sbin/mount | /usr/bin/grep ramdisk0"
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
    content => template("ibm_sc/id_rsa.erb"),
    mode    => 0600,
    owner   => 'puppet'
  }->
  file { "/.ssh":
    ensure => 'directory',
    mode    => 0600,
    owner   => 'root'
  }->
  file { "/.ssh/id_rsa":
    content => template("ibm_sc/id_rsa.erb"),
    mode    => 0600,
    owner   => 'root'
  }->
  exec { "/usr/bin/git clone git@github.com:sugarcrm/AutoUtils.git":
    command => "/usr/bin/git clone git@github.com:sugarcrm/AutoUtils.git /srv/AutoUtils",
    creates => "/srv/AutoUtils"
  }->
  exec { "/usr/bin/cpan YAML":
    command => "/usr/bin/cpan YAML"
  }

  $memory_limit = '2048M'
  $error_reporting = 'E_ALL'

  file {"/opt/freeware/etc/php.ini":
    content => template('ibm_sc/php.ini.erb'),
    owner   => 'root',
    mode    => 0644,
    require => File['/opt/freeware/bin/php'],
    ensure => 'present',
    notify  => Exec['/opt/freeware/sbin/httpd -k restart'],
  }

  exec { '/opt/freeware/sbin/httpd -k restart':
    command => '/opt/freeware/sbin/httpd -k restart'
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
    content => inline_template("
nameserver     10.8.1.101
domain  cup1.sugarcrm.net
      ")
  }

  exec { "change db2 port to 50000":
    command => "/usr/bin/sed 's/50001/50000/g' /etc/services > /tmp/service.tmp; mv /tmp/service.tmp /etc/services",
    unless => '/usr/bin/grep "db2c_db2inst1 50000/tcp" /etc/services'
  }

  file { "/opt/freeware/etc/httpd/conf/extra/server-tuning.conf":
    content => inline_template("
StartServers 2
MinSpareServers 25
MaxSpareServers 50
ServerLimit 800
MaxClients 800
MaxRequestsPerChild 0
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 60
    "),
    require => File['/opt/freeware/sbin/httpd'],
    owner   => 'root',
    mode    => 0644,
    ensure => 'present',
  }->
  file { "/opt/freeware/etc/httpd/conf/httpd.conf":
    content => template('ibm_sc/httpd.conf.erb'),
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
    content => "
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/java5/jre/bin:/usr/java5/bin:/opt/freeware/bin:/opt/freeware/bin/sbin
TZ=America/Los_Angeles
LANG=en_US
LOCPATH=/usr/lib/nls/loc
NLSPATH=/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/%L/%N.cat:/usr/lib/nls/msg/%l.%c/%N:/usr/lib/nls/msg/%l.%c/%N.cat
LC__FASTMSG=true

# ODM routines use ODMDIR to determine which objects to operate on
# the default is /etc/objrepos - this is where the device objects
# reside, which are required for hardware configuration

ODMDIR=/etc/objrepos
# Clustering variable to allow commands to bypass clcmd checks.
CLCMD_PASSTHRU=1

# Increases the process memory so phpunit will not run out of memory
export LDR_CNTRL=MAXDATA=0x20000000
"
  }

  file { "/home/db2inst1/sqllib/profile.env":
    content => "
DB2_COMPATIBILITY_VECTOR='4008'
DB2COMM='TCPIP'
DB2CODEPAGE='1208'
DB2AUTOSTART='YES'
    ",
    owner => 'db2inst1',
    ensure => 'present'
  }

  exec { "/usr/sbin/chps -s 39 hd6":
    command => "/usr/sbin/chps -s 39 hd6",
    unless => "/usr/sbin/lsps -a | /usr/bin/grep hd6 | /usr/bin/grep 5504MB"
  }
}

node /^aix-qa-/ {
  include aix
}

node /^sugareps-centos-/ {
  package { 'php':
    ensure          => installed
  }

  package { 'php-common':
    ensure          => installed
  }

  package { 'php-cli':
    ensure          => installed
  }
}
