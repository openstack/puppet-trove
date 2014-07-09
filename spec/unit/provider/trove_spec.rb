require 'puppet'
require 'spec_helper'
require 'puppet/provider/trove'


klass = Puppet::Provider::Trove

describe Puppet::Provider::Trove do

  after :each do
    klass.reset
  end

end
