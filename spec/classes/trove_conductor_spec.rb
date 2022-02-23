require 'spec_helper'

describe 'trove::conductor' do

  shared_examples 'trove-conductor' do

    context 'with default parameters' do
      it 'includes required classes' do
        is_expected.to contain_class('trove::deps')
        is_expected.to contain_class('trove::params')
      end

      it 'installs trove-conductor package and service' do
        is_expected.to contain_service('trove-conductor').with(
          :name      => platform_params[:conductor_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        is_expected.to contain_package('trove-conductor').with(
          :name   => platform_params[:conductor_package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package'],
        )
      end

      it 'configures trove-conductor with default parameters' do
        is_expected.to contain_trove_config('DEFAULT/trove_conductor_workers').with_value('8')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({ :os_workers => 8 }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :conductor_package_name => 'trove-conductor',
            :conductor_service_name => 'trove-conductor' }
        when 'RedHat'
          { :conductor_package_name => 'openstack-trove-conductor',
            :conductor_service_name => 'openstack-trove-conductor' }
        end
      end
      it_configures 'trove-conductor'
    end
  end

end
