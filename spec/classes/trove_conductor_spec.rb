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
          :tag    => ['openstack', 'trove-package'],
        )
      end

      it 'configures trove-conductor with default parameters' do
        is_expected.to contain_trove_conductor_config('DEFAULT/verbose').with_value(false)
        is_expected.to contain_trove_conductor_config('DEFAULT/debug').with_value(false)
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_userid').with_value('guest')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_password').with_value('guest')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value(false)
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(false)
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('false')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('false')
        end
      end

      context 'when using a single RabbitMQ server with enable ha options' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_ha_queues      => 'true',
             amqp_durable_queues   => 'true',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('true')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
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

    context 'with SSL enabled with kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => true,
           kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
           kombu_ssl_certfile => '/path/to/ssl/cert/file',
           kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
           kombu_ssl_version  => 'TLSv1'}"
      end

      it do
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with SSL enabled without kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => true}"
      end

      it do
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with SSL disabled' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => false,
           kombu_ssl_version  => 'TLSv1'}"
      end

      it do
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'Debian',
        :processorcount => 8,
      })
    end

    let :platform_params do
      { :conductor_package_name => 'trove-conductor',
        :conductor_service_name => 'trove-conductor' }
    end

    it_configures 'trove-conductor'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'RedHat',
        :processorcount => 8,
      })
    end

    let :platform_params do
      { :conductor_package_name => 'openstack-trove-conductor',
        :conductor_service_name => 'openstack-trove-conductor' }
    end

    it_configures 'trove-conductor'
  end

end
