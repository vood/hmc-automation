require 'profile'

describe Profile do
  describe '#initialize' do
    it 'accepts dictionary' do
      dic = {:test => 'test'}
      profile = Profile.new(dic)
      profile.to_s
    end
  end
  describe '#add_client_scsi_adapter' do
    it 'adds adapter' do
      dic = {:test => 'test'}
      profile = Profile.new(dic)
      profile.add_client_scsi_adapter(1, 'VIOS1', 5)
      profile.add_client_scsi_adapter(2, 'VIOS2', 5)
      profile.to_s.include?('"virtual_scsi_adapters=1/client//VIOS1/5/1,2/client//VIOS2/5/1"').should be_true
    end
  end
  describe '#add_client_scsi_adapter_to_spare_slot' do
    it 'adds adapter to spare slot' do
      dic = {:test => 'test'}
      profile = Profile.new(dic)
      profile.add_client_scsi_adapter_to_spare_slot('VIOS', 5)
      profile.add_client_scsi_adapter_to_spare_slot('VIOS', 5)
      profile.to_s.include?('"virtual_scsi_adapters=3/client//VIOS/5/1,4/client//VIOS/5/1"').should be_true
    end
  end
end
