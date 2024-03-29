require File.join(File.dirname(__FILE__), "..","..","..",
                  "puppet/provider/trove")

Puppet::Type.type(:trove_datastore).provide(
  :trove,
  :parent => Puppet::Provider::Trove
) do
  desc <<-EOT
    Trove provider to manage datastore type.
  EOT

  mk_resource_methods

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  def self.instances
    request('datastore', 'list').collect do |attrs|
      new(
        :ensure => :present,
        :name   => attrs[:name],
        :id     => attrs[:id]
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
    trove_manage(['datastore_update', "#{@resource[:name]}", "''"])

    if @resource[:version]
      trove_manage(['datastore_update', "#{@resource[:name]}", "#{@resource[:version]}"])
    end
  end
end

