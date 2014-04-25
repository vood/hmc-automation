require_relative 'ssh_client'

class LPAR < SSHClient

  def initialize(host, user, password)
    super(host, user, password)
  end

  def install_puppet
    self.make_tmp_dir
    self.download_rpms
    self.install_rpms
    self.install_puppet_gem
    self.fix_path
    self.create_user
    self.make_config
    self.cleanup
  end

  def make_tmp_dir
    self.exec("rm -rf /tmp/downloads")
    self.exec("mkdir /tmp/downloads")
    self.exec("cd /tmp/downloads")
  end

  def download_rpms

    self.exec("rpm -Uvh ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/wget/wget-1.9.1-1.aix5.1.ppc.rpm")
    self.download("-P /tmp/downloads ftp://www.oss4aix.org/rpmdb/deplists/aix71/ruby-2.0.0.353-1.aix5.1.ppc.deps")
    self.download("-P /tmp/downloads -B ftp://www.oss4aix.org/everything/RPMS/ -i /tmp/downloads/ruby-2.0.0.353-1.aix5.1.ppc.deps")
  end

  def install_rpms
    self.exec("rpm -Uvh --replacepkgs /tmp/downloads/*.rpm")
  end

  def install_puppet_gem
    self.exec("gem install puppet")
  end

  def make_config
    self.exec("mkdir /etc/puppet")
    self.exec("touch /etc/puppet/puppet.conf")
  end

  def cleanup
    self.exec("rm -rf /tmp/downloads")
  end

  def download url
    self.exec("wget #{url}")
  end

  def fix_path
    self.exec("export PATH=$PATH:/opt/freeware/bin")
  end

  def create_user
    self.exec("puppet resource group puppet ensure=present")
    self.exec("puppet resource user puppet ensure=present gid=puppet")
  end

end