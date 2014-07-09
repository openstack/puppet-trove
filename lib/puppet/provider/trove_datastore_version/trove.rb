require File.join(File.dirname(__FILE__), "..","..","..",
                  "puppet/provider/trove")

Puppet::Type.type(:trove_datastore_version).provide(
  :trove,
  :parent => Puppet::Provider::Trove
) do
  desc <<-EOT
    Trove provider to manage datastore version type.
  EOT

  commands :trove => "trove"

  mk_resource_methods

  def self.prefetch(resource)
    @datastore_version_hash = nil
  end

  def self.datastore_version_hash(datastore)
    @datastore_version_hash ||= build_datastore_version_hash(datastore)
  end

  def datastore_version_hash(datastore)
    self.class.datastore_version_hash(datastore)
  end

  def self.instances
    []
  end

  def exists?
    datastore_version_hash(resource[:datastore])[resource[:name]]
  end

  def create
    cmd = ['trove-manage', 'datastore_version_update',
           "#{@resource[:datastore]}", "#{@resource[:name]}",
           "#{@resource[:manager]}", "#{@resource[:image_id]}",
           "#{@resource[:packages]}", "#{@resource[:active]}"]
    if trove_manage(cmd) != 0
      fail("Failed to create datastore version #{@resource[:name]}")
    end
  end

  def destroy
    fail("Datastore version cannot be removed")
  end

  private

    def self.build_datastore_version_hash(datastore)
      dvs = {}
      list_trove_resources("datastore-version", datastore).collect do |attrs|
        dvs[attrs["name"]] = attrs
      end
      dvs
    end

end
