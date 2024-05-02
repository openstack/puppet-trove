# Add openstacklib code to $LOAD_PATH so that we can load this during
# standalone compiles without error.
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'

class Puppet::Provider::Trove < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  initvars # so commands will work
  commands :trove_manage => 'trove-manage'

  def trove_manage(*args)
    execute([command(:trove_manage)] + args)
  end
end
