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

  let :datastore_attrs do
    {
      :name   => datastore_name,
      :ensure => 'present',
    }
  end

  let :resource do
    Puppet::Type::Trove_datastore.new(datastore_attrs)
  end

  let :provider do
    described_class.new(resource)
  end

  before :each do
    set_env
  end

  describe "self.instances" do
    it 'lists datastores' do
      expect(provider_class).to receive(:openstack)
        .with('datastore', 'list', '--quiet', '--format', 'csv', [])
        .and_return('"ID","Name"
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
    context 'without version' do
      it 'creates datastore' do
        expect(provider).to receive(:trove_manage)
          .with(['datastore_update', datastore_name, "''"])
          .and_return(0)
        provider.create
      end
    end

    context 'with version' do
      before do
        datastore_attrs.merge!(
          :version => '0.1',
        )
      end

      it 'creates datastore' do
        expect(provider).to receive(:trove_manage)
          .with(['datastore_update', datastore_name, "''"])
          .and_return(0)

        expect(provider).to receive(:trove_manage)
          .with(['datastore_update', datastore_name, "0.1"])
          .and_return(0)
        provider.create
      end
    end
  end
end
