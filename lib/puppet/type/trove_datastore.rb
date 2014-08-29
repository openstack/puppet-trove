Puppet::Type.newtype(:trove_datastore) do

  @doc = "Manage creation of Trove datastores"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Datastore version name)"
    newvalues(/^.*$/)
  end

  newparam(:version) do
    desc "Datastore version name"
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  validate do
    raise(Puppet::Error, 'Version must be set') unless self[:version]
  end
end

