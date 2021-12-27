Puppet::Type.type(:trove_conductor_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/trove/trove-conductor.conf'
  end

end
