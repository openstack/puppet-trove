require 'spec_helper'

describe 'trove::guestagent' do

  shared_examples 'trove-guestagent' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass => 'verysecrete'}"
      end

      it 'installs trove-guestagent package and service' do
        should contain_service('trove-guestagent').with(
          :name      => platform_params[:guestagent_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        should contain_package('trove-guestagent').with(
          :name   => platform_params[:guestagent_package_name],
          :ensure => 'present',
          :notify => 'Service[trove-guestagent]'
        )
      end

      it 'configures trove-guestagent with default parameters' do
        should contain_trove_guestagent_config('DEFAULT/verbose').with_value(false)
        should contain_trove_guestagent_config('DEFAULT/debug').with_value(false)
        should contain_trove_guestagent_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        should contain_trove_guestagent_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        should contain_trove_guestagent_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-guestagent with RabbitMQ' do
          should contain_trove_guestagent_config('DEFAULT/rabbit_host').with_value('10.0.0.1')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-guestagent with RabbitMQ' do
          should contain_trove_guestagent_config('DEFAULT/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
        end
      end
    end

    context 'with custom parameters' do
      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass => 'verysecrete'}"
      end

      let :params do
        { :auth_url => "http://10.0.0.1:5000/v2.0",
          :swift_url => "http://10.0.0.1:8080/v1/AUTH_" }
      end
      it 'configures trove-guestagent with custom parameters' do
        should contain_trove_guestagent_config('DEFAULT/trove_auth_url').with_value('http://10.0.0.1:5000/v2.0')
        should contain_trove_guestagent_config('DEFAULT/swift_url').with_value('http://10.0.0.1:8080/v1/AUTH_')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => 8 }
    end

    let :platform_params do
      { :guestagent_package_name => 'trove-guestagent',
        :guestagent_service_name => 'trove-guestagent' }
    end

    it_configures 'trove-guestagent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => 8 }
    end

    let :platform_params do
      { :guestagent_package_name => 'openstack-trove-guestagent',
        :guestagent_service_name => 'openstack-trove-guestagent' }
    end

    it_configures 'trove-guestagent'
  end

end
