Puppet::Type.type(:trove_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/trove/trove.conf'
  end

end
