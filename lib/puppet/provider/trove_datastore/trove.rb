require File.join(File.dirname(__FILE__), "..","..","..",
                  "puppet/provider/trove")

Puppet::Type.type(:trove_datastore).provide(
  :trove,
  :parent => Puppet::Provider::Trove
) do
  desc <<-EOT
    Trove provider to manage datastore type.
  EOT

  commands :trove => "trove"

  mk_resource_methods

  def self.instances
    list_trove_resources("datastore").collect do |attrs|
      new(
        :ensure         => :present,
        :name           => attrs["name"],
        :id             => attrs["id"]
      )
    end
  end

  def self.prefetch(resources)
    instances_ = instances
    resources.keys.each do |name|
      if provider = instances_.find{ |instance| instance.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if trove_manage(['trove-manage', 'datastore_update',
                     "#{@resource[:name]}", "''"]) != 0
      fail("Failed to create datastore #{@resource[:name]}")
    end

    if trove_manage(['trove-manage', 'datastore_update',
                     "#{@resource[:name]}", "#{@resource[:version]}"]) != 0
      fail("Failed to set version for datastore #{@resource[:name]}")
    end
  end

end

