require 'spec_helper'

describe 'trove::conductor' do

  shared_examples 'trove-conductor' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass => 'verysecrete'}"
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
          :notify => 'Service[trove-conductor]'
        )
      end

      it 'configures trove-conductor with default parameters' do
        is_expected.to contain_trove_conductor_config('DEFAULT/verbose').with_value(false)
        is_expected.to contain_trove_conductor_config('DEFAULT/debug').with_value(false)
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('DEFAULT/rabbit_host').with_value('10.0.0.1')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('DEFAULT/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
        end
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             database_connection   => 'mysql://trove:pass@10.0.0.1/trove'}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('database/connection').with_value('mysql://trove:pass@10.0.0.1/trove')
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => 8 }
    end

    let :platform_params do
      { :conductor_package_name => 'trove-conductor',
        :conductor_service_name => 'trove-conductor' }
    end

    it_configures 'trove-conductor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => 8 }
    end

    let :platform_params do
      { :conductor_package_name => 'openstack-trove-conductor',
        :conductor_service_name => 'openstack-trove-conductor' }
    end

    it_configures 'trove-conductor'
  end

end
