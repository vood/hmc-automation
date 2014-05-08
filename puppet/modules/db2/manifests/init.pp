class db2 {
  $tmp = "/tmp/ibmdb2expc"
  file { "$tmp":
    ensure => "directory"
  }->
  exec { "/usr/bin/wget http://10.8.7.188/v10.5fp1_linuxx64_expc.tar.gz":
    command => "/usr/bin/wget http://10.8.7.188/v10.5fp1_linuxx64_expc.tar.gz -O $tmp/ibm.tar.gz",
    creates => "$tmp/ibm.tar.gz"
  }->
  file { "$tmp/db2expc.rsp":
    content => template("db2/db2expc.rsp.erb")
  }->
  exec { "/bin/tar zxf $tmp/ibm.tar.gz -C $tmp":
    command => "/bin/tar zxf $tmp/ibm.tar.gz -C $tmp",
    creates => "$tmp/expc/db2setup"
  }->
  exec { "$tmp/expc/db2setup -f sysreq -r $tmp/db2expc.rsp":
    command => "$tmp/expc/db2setup -f sysreq -r $tmp/db2expc.rsp",
    timeout => 1800,
    creates => '/opt/ibm/db2/V10.5/bin/db2'
  }->
  file { "/home/db2inst1/sqllib/adm/.fenced":
    owner => "db2inst1",
    group => "db2iadm1"
  }

  package {
   ['compat-libstdc++-33',
    'compat-libstdc++-33.i686',
    'libaio',
    'libaio.i686',
    'pam-1.1.1-17.el6.x86_64',
    'pam-1.1.1-17.el6.i686',
    'nfs-utils']:
    ensure => 'installed',
    before => File["$tmp"]
  }
}