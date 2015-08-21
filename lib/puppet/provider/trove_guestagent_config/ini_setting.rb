Puppet::Type.type(:trove_guestagent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/trove/trove-guestagent.conf'
  end

end
