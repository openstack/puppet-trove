require 'puppet'
require 'spec_helper'
require 'puppet/provider/trove_datastore_version/trove'

provider_class = Puppet::Type.type(:trove_datastore_version).provider(:trove)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  let :datastore_name do
    'mysql'
  end

  let :datastore_version do
    '5.7.29'
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

  before :each do
    set_env
  end

  describe "#instances" do
    it "should have an instances method" do
      expect(provider.class).to respond_to(:instances)
    end
  end

  describe '#create' do
    it 'should call trove-manage' do
      expect(provider). to receive(:trove_manage).with(
        ['trove-manage', 'datastore_version_update', datastore_name,
         datastore_version, 'mysql', '1234', 'mysql', '1']
      ).and_return(0)

      provider.create
    end
  end

  describe '#exists' do
    it 'should list datastore versions' do
      expect(provider_class).to receive(:openstack)
        .with('datastore version', 'list', '--quiet', '--format', 'csv',
              datastore_name)
        .and_return('"ID","Name","Version"
"9c4d3fb1-644c-4543-9c37-49b3a801b66c","5.7.29","5.7.29"
"406b75fb-0727-4923-a702-d677e3fd84ab","5.7.30","5.7.30"
')
      expect(provider.exists?).to be_truthy
    end
  end
end
