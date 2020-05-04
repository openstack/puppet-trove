require 'puppet'
require 'puppet/type/trove_guestagent_config'

describe 'Puppet::Type.type(:trove_guestagent_config)' do
  before :each do
    @trove_guestagent_config = Puppet::Type.type(:trove_guestagent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that installs the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'trove::install::end')
    catalog.add_resource anchor, @trove_guestagent_config
    dependency = @trove_guestagent_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@trove_guestagent_config)
    expect(dependency[0].source).to eq(anchor)
  end
end
