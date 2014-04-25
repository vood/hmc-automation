require 'net/ssh'
require_relative 'ssh_client'

class HMC < SSHClient

  def initialize(host, user, password, managed_server)
    super(host, user, password)
    @managed_server = managed_server
  end

  def create_lpar(lpar_name, profile)
    cmd = "mksyscfg -r lpar -m #{@managed_server} -i name=#{lpar_name},#{profile}"
    self.exec(cmd)
  end

  def remove_lpar(lpar_name)
    cmd = "rmsyscfg -r lpar -m #{@managed_server} -n #{lpar_name}"
    self.exec(cmd)
  end

  def add_server_scsi_adapter(lpar_name, slot = nil)
    self.add_scsi_adapter(lpar_name, 'server', '', '', '', slot)
  end

  def add_client_scsi_adapter(lpar_name, remote_lpar_id, remote_lpar_name, remote_lpar_slot, slot = nil)
    self.add_scsi_adapter(lpar_name, 'client', remote_lpar_id, remote_lpar_name, remote_lpar_slot, slot)
  end

  def get_next_avail_virtual_slot(lpar_name)
    self.exec("lshwres -m #{@managed_server} -r virtualio --rsubtype slot --level lpar --filter lpar_names=#{lpar_name} -F next_avail_virtual_slot").to_i
  end

  def add_scsi_adapter(lpar_name, type, remote_lpar_id, remote_lpar_name, remote_slot_number, slot = nil)
    slot ||= self.get_next_avail_virtual_slot(lpar_name)
    attrs = {
        :adapter_type => type,
        :remote_lpar_id => remote_lpar_id,
        :remote_lpar_name => remote_lpar_name,
        :remote_slot_num => remote_slot_number
    }
    a = attrs.select { |k, v| v.to_s.length > 0 }.map { |k,v| "#{k}=#{v}" }.join(",")
    cmd = "chhwres -m #{@managed_server} -r virtualio --rsubtype scsi -o a -s #{slot} -p #{lpar_name} -a #{a}"
    self.exec(cmd)
  end

  def remove_scsi_adapter(lpar_name, id)
    raise ::NotImplementedError
  end

  def activate_lpar_profile(lpar_name, profile, boot_mode = 'norm')
    cmd = "chsysstate -r lpar -m #{@managed_server} -o on -n #{lpar_name} -f #{profile} -b #{boot_mode}"
    self.exec(cmd)
  end

  def activate_lpar(lpar_name)
    cmd = "chsysstate -r lpar -m #{@managed_server} -o on -n #{lpar_name}"
    self.exec(cmd)
  end

  def shutdown_lpar(lpar_name)
    cmd = "chsysstate -r lpar -m #{@managed_server} -o shutdown -n #{lpar_name}"
    self.exec(cmd)
  end

end