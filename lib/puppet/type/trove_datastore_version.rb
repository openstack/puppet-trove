Puppet::Type.newtype(:trove_datastore_version) do

  @doc = "Manage creation of Trove datastore versions"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Datastore version"
  end

  newparam(:datastore) do
    desc "Datastore name)"
  end

  newparam(:manager) do
    desc "Manager name"
  end

  newparam(:image_id) do
    desc "Glance image id"
  end

  newparam(:packages) do
    desc "Packages to install"
  end

  newparam(:active) do
    desc "State"
  end

  validate do
    raise(Puppet::Error, 'Datastore must be set') unless self[:datastore]
    raise(Puppet::Error, 'Manager must be set') unless self[:manager]
    raise(Puppet::Error, 'Image must be set') unless self[:image_id]
    raise(Puppet::Error, 'Packages must be set') unless self[:packages]
    raise(Puppet::Error, 'State must be set') unless self[:active]
  end
end
