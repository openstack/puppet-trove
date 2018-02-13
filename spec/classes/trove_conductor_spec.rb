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
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_conductor_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_conductor_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_conductor_config('DEFAULT/remote_nova_client').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('DEFAULT/remote_cinder_client').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('DEFAULT/remote_neutron_client').with_ensure('absent')
        is_expected.to contain_trove_conductor_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_userid').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('DEFAULT/trove_conductor_workers').with_value('8')
        is_expected.to contain_trove_conductor_config('profiler/enabled').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('profiler/trace_sqlalchemy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__messaging__rabbit('trove_conductor_config').with(
          :rabbit_use_ssl => '<SERVICE DEFAULT>',
        )
      end

      it 'configures trove-conductor with default logging parameters' do
        is_expected.to contain_oslo__log('trove_conductor_config').with(
          :use_syslog          => '<SERVICE DEFAULT>',
          :syslog_log_facility => '<SERVICE DEFAULT>',
          :log_dir             => '/var/log/trove',
          :log_file            => '/var/log/trove/trove-conductor.log',
          :debug               => '<SERVICE DEFAULT>',
        )
      end

      context 'with single tenant mode enabled' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             single_tenant_mode    => 'true'}
           class { '::trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end
        it 'single tenant client values are set' do
          is_expected.to contain_trove_conductor_config('DEFAULT/remote_nova_client').with_value('trove.common.single_tenant_remote.nova_client_trove_admin')
          is_expected.to contain_trove_conductor_config('DEFAULT/remote_cinder_client').with_value('trove.common.single_tenant_remote.cinder_client_trove_admin')
          is_expected.to contain_trove_conductor_config('DEFAULT/remote_neutron_client').with_value('trove.common.single_tenant_remote.neutron_client_trove_admin')
        end
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-conductor with RabbitMQ' do
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_trove_conductor_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
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
        is_expected.to contain_oslo__messaging__rabbit('trove_conductor_config').with(
          :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
          :kombu_ssl_certfile => '/path/to/ssl/cert/file',
          :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
          :kombu_ssl_version  => 'TLSv1',
        )
      end
    end

    context 'with SSL enabled without kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl        => true}"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_conductor_config').with(
          :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile  => '<SERVICE DEFAULT>',
          :kombu_ssl_version  => '<SERVICE DEFAULT>',
        )
      end
    end

    context 'with SSL disabled' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl        => false}"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_conductor_config').with(
          :rabbit_use_ssl     => false,
          :kombu_ssl_ca_certs => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile  => '<SERVICE DEFAULT>',
          :kombu_ssl_version  => '<SERVICE DEFAULT>',
        )
      end
    end

    context 'with transport_url entries' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass      => 'verysecrete',
           default_transport_url      => 'rabbit://rabbit_user:password@localhost:5673',
           rpc_response_timeout       => '120',
           control_exchange           => 'openstack',
           notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673' }"
      end

      it do
        is_expected.to contain_trove_conductor_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_conductor_config('DEFAULT/rpc_response_timeout').with_value('120')
        is_expected.to contain_trove_conductor_config('DEFAULT/control_exchange').with_value('openstack')
        is_expected.to contain_trove_conductor_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp messaging' do
      let :pre_condition do
        "class { 'trove' :
           nova_proxy_admin_pass => 'verysecrete'}"
      end

      it do
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_conductor_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
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
