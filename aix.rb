require 'net/ssh'
require 'yaml'
require 'logger'
require_relative 'lib/hmc'
require_relative 'lib/vios'
require_relative 'lib/profile'

config = YAML.load_file('config/config.yml')

aix = 'AIX-QA-3'

env = 'dev'

log = Logger.new(STDOUT)

config = config[env]

template = config['lpar_templates']['aix']

vios_config = config['hmc']['servers'][config['hmc']['servers'].keys[0]]['vios']

hmc_config = config['hmc']

hmc = HMC.new(hmc_config['host'], hmc_config['user'], hmc_config['password'], hmc_config['servers'].keys[0])

vios = VIOS.new(vios_config['host'], vios_config['user'], vios_config['password'])

begin

  name = vios.create_vdisk(vios_config['vg'], aix, template['storage']['size'])

  slot = hmc.get_next_avail_virtual_slot(vios_config['name'])

  hmc.add_server_scsi_adapter(vios_config['name'], slot)

  vios.latest_vhost

  vios.make_vdev(name, vios.latest_vhost)

  profile = Profile.new(template['profile'])

  profile.add_client_scsi_adapter_to_spare_slot(vios_config['name'], slot)

  profile.add_client_scsi_adapter_to_spare_slot(vios_config['name'], 9, 0)

  #profile.add_client_scsi_adapter_to_spare_slot(vios_config['name'], 5, 0)

  hmc.create_lpar(aix, profile)

  hmc.activate_lpar_profile(aix, template['profile']['profile_name'])

rescue Exception => e
  log.error e
end