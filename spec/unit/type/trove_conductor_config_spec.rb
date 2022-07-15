require 'puppet'
require 'puppet/type/trove_conductor_config'

describe 'Puppet::Type.type(:trove_conductor_config)' do
  before :each do
    @trove_conductor_config = Puppet::Type.type(:trove_conductor_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:trove_conductor_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:trove_conductor_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:trove_conductor_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:trove_conductor_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @trove_conductor_config[:value] = 'bar'
    expect(@trove_conductor_config[:value]).to eq(['bar'])
  end

  it 'should accept a value with whitespace' do
    @trove_conductor_config[:value] = 'b ar'
    expect(@trove_conductor_config[:value]).to eq(['b ar'])
  end

  it 'should accept valid ensure values' do
    @trove_conductor_config[:ensure] = :present
    expect(@trove_conductor_config[:ensure]).to eq(:present)
    @trove_conductor_config[:ensure] = :absent
    expect(@trove_conductor_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @trove_conductor_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
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
