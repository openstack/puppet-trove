require 'puppet/type/trove_guestagent_config'

describe 'Puppet::Type.type(:trove_guestagent_config)' do
  before :each do
    @trove_guestagent_config = Puppet::Type.type(:trove_guestagent_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that installs the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'trove-guestagent')
    catalog.add_resource package, @trove_guestagent_config
    dependency = @trove_guestagent_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@trove_guestagent_config)
    expect(dependency[0].source).to eq(package)
  end
end
