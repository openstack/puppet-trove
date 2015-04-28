require 'puppet'
require 'spec_helper'
require 'puppet/provider/trove_datastore/trove'

provider_class = Puppet::Type.type(:trove_datastore).provider(:trove)

describe provider_class do

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
    described_class.stubs(:list_trove_resources).with('datastore').returns([
       resource
    ])
  end

  describe "self.instances" do
    it "should have an instances method" do
      expect(provider.class).to respond_to(:instances)
    end

    it "should list instances" do
      datastores = described_class.instances
      expect(datastores.size).to eq(1)
      datastores.map {|provider| provider.name} == datastore_name
    end
  end

  describe '#create' do
    it 'should call trove-manage' do
      provider.expects(:trove_manage).with(
        ['trove-manage', 'datastore_update', datastore_name, "''"]
      ).returns(0)

      provider.expects(:trove_manage).with(
        ['trove-manage', 'datastore_update', datastore_name, "0.1"]
      ).returns(0)

      provider.create
    end
  end

end
