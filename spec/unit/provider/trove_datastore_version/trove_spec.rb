require 'puppet'
require 'spec_helper'
require 'puppet/provider/trove_datastore_version/trove'

provider_class = Puppet::Type.type(:trove_datastore_version).provider(:trove)

describe provider_class do

  let :datastore_name do
    'foo'
  end

  let :datastore_version do
    '1.0'
  end

  let :resource do
    Puppet::Type::Trove_datastore_version.new({
      :name         => datastore_version,
      :ensure       => 'present',
      :datastore    => datastore_name,
      :manager      => 'mysql',
      :image_id     => '1234',
      :packages     => 'mysql',
      :active       => 1
    })
  end

  let :provider do
    described_class.new(resource)
  end

  describe "self.instances" do
    it "should have an instances method" do
      expect(provider.class).to respond_to(:instances)
    end
  end

  describe '#create' do
    it 'should call trove-manage' do
      provider.expects(:trove_manage).with(
        ['trove-manage', 'datastore_version_update', datastore_name, "1.0",
         'mysql', '1234', 'mysql', '1']
      ).returns(0)

      provider.create
    end
  end

end
