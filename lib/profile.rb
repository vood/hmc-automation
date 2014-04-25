class Profile

  def initialize(profile)
    @profile = profile
    @slot_count = 2
  end

  def add_client_scsi_adapter(slot_id, remote_lrar_name, remote_lpar_slot, required = 1)
    adapter = [slot_id, 'client', '', remote_lrar_name, remote_lpar_slot, required.to_i].join('/')
    @profile['virtual_scsi_adapters'] ||= []
    @profile['virtual_scsi_adapters'] << adapter
    @slot_count += 1
  end

  def add_client_scsi_adapter_to_spare_slot(remote_lrar_name, remote_lpar_slot, required = 1)
    self.add_client_scsi_adapter(@slot_count + 1, remote_lrar_name, remote_lpar_slot, required)
  end

  def to_s
    @profile.map do |k,v|
      result = "#{k}=#{v}"
      result = "\\\"#{k}=#{v.join(',')}\\\"" if v.is_a?(Array)
      result
    end.join(',')
  end

end