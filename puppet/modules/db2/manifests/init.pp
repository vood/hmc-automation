class db2 {
  exec { '/usr/bin/wget "http://10.8.7.188/v10.5fp1_linuxx64_expc.tar.gz':
    command => '/usr/bin/wget "http://10.8.7.188/v10.5fp1_linuxx64_expc.tar.gz -O /tmp/ibm.tar.gz',
    creates => '/tmp/ibm.tar.gz'
  }->
  file { '/tmp/db2expc.rsp':
    content => template('db2/db2expc.rsp.erb')
  }->
  exec { '/usr/bin/tar zxf /tmp/ibm.tar.gz':
    command => '/usr/bin/tar zxf /tmp/ibm.tar.gz',
    creates => '/tmp/ibm/db2setup.sh'
  }->
  exec { '/tmp/ibm/db2setup -f sysreq -r /tmp/db2expc.rsp':
    command => '/tmp/ibm/db2setup -f sysreq -r /tmp/db2expc.rsp',
    timeout => 1800
  }->
  file { '/home/db2inst1/sqllib/adm/.fenced':
    owner => 'db2inst1',
    group => 'db2iadm1'
  }
}