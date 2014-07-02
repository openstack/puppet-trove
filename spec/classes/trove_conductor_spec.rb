require 'spec_helper'

describe 'trove::conductor' do

  let :pre_condition do
    'include trove'
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_behaves_like 'generic trove service', {
      :name         => 'trove-conductor',
      :package_name => 'trove-conductor',
      :service_name => 'trove-conductor' }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_behaves_like 'generic trove service', {
      :name         => 'trove-conductor',
      :package_name => 'openstack-trove-conductor',
      :service_name => 'openstack-trove-conductor' }
  end
end
