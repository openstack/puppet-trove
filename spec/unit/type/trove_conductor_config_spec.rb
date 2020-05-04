require 'puppet'
require 'puppet/type/trove_conductor_config'

describe 'Puppet::Type.type(:trove_conductor_config)' do
  before :each do
    @trove_conductor_config = Puppet::Type.type(:trove_conductor_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that installs the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'trove::install::end')
    catalog.add_resource anchor, @trove_conductor_config
    dependency = @trove_conductor_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@trove_conductor_config)
    expect(dependency[0].source).to eq(anchor)
  end
end
