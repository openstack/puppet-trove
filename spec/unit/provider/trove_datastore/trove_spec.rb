require 'puppet'
require 'spec_helper'
require 'puppet/provider/trove_datastore/trove'

provider_class = Puppet::Type.type(:trove_datastore).provider(:trove)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  let :datastore_name do
    'foo'
  end

  let :resource do
    Puppet::Type::Trove_datastore.new({
      :name         => datastore_name,
      :version      => '0.1',
      :ensure       => 'present',
    })
  end

  let :provider do
    described_class.new(resource)
  end

  before :each do
    set_env
  end

  describe "self.instances" do
    it 'lists datastores' do
      provider_class.expects(:openstack)
        .with('datastore', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name"
"1275b24c-73af-4c51-98ec-c9938a94a153","store1"
"18088802-efe2-42f8-ac85-ecfddd37d24e","store2"
')
      instances = provider_class.instances
      expect(instances.length).to eq(2)
      expect(instances[0].id).to eq('1275b24c-73af-4c51-98ec-c9938a94a153')
      expect(instances[0].name).to eq('store1')
      expect(instances[1].id).to eq('18088802-efe2-42f8-ac85-ecfddd37d24e')
      expect(instances[1].name).to eq('store2')
    end
  end

  describe '#create' do
    it 'creates datastore' do
      provider.expects(:trove_manage)
        .with(['trove-manage', 'datastore_update', datastore_name, "''"])
        .returns(0)

      provider.expects(:trove_manage)
        .with(['trove-manage', 'datastore_update', datastore_name, "0.1"])
        .returns(0)

      provider.create
    end
  end

end
