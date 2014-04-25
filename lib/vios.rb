require 'net/ssh'
require_relative 'ssh_client'

class VIOS < SSHClient

  def create_vdisk(vg_name, prefix, size_gb)
    name =  "#{vg_name}-#{self.vdisk_count(vg_name)}".gsub('-', '_').downcase
    cmd = "ioscli mkbdsp -sp datavg #{size_gb}G -bd #{name}"
    self.exec(cmd)
    name
  end

  def remove_vdisk(vdisk_name)
    cmd = "ioscli rmbdsp -bd #{vdisk_name}"
    self.exec(cmd)
    true
  end

  def vdisk_count(vg_name)
    cmd = "ioscli lsvg #{vg_name}"
    response = self.exec(cmd)
    /^LVs:\s+(?<count>\d+)\s+/.match(response)[:count].to_i + 3
  end

  def make_vdev(hdisk, vadapter)
    cmd = "ioscli mkvdev -vdev #{hdisk} -vadapter #{vadapter}"
    self.exec(cmd)
  end

  def latest_vhost
    cmd = "ioscli lsdev -virtual | grep vhost"
    result = self.exec(cmd)
    result.split("\n").last.split(" ")[0]
  end
end