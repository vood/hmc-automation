require 'lpar'

describe LPAR do
  describe '#install_puppet' do
    it 'installs puppet' do
      lpar = LPAR.new('10.8.7.181', 'root', 'root')
      lpar.install_puppet
    end
  end
end
