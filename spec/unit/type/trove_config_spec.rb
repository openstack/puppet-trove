require 'puppet'
require 'puppet/type/trove_config'
describe 'Puppet::Type.type(:trove_config)' do
  before :each do
    @trove_config = Puppet::Type.type(:trove_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:trove_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:trove_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:trove_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:trove_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @trove_config[:value] = 'bar'
    @trove_config[:value].should == 'bar'
  end

  it 'should not accept a value with whitespace' do
    @trove_config[:value] = 'b ar'
    @trove_config[:value].should == 'b ar'
  end

  it 'should accept valid ensure values' do
    @trove_config[:ensure] = :present
    @trove_config[:ensure].should == :present
    @trove_config[:ensure] = :absent
    @trove_config[:ensure].should == :absent
  end

  it 'should not accept invalid ensure values' do
    expect {
      @trove_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end
end
