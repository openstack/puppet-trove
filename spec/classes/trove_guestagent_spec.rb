require 'spec_helper'

describe 'trove::guestagent' do

  shared_examples 'trove-guestagent' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         os_region_name        => 'RegionOne',
         nova_proxy_admin_pass => 'verysecrete'}"
      end

      it 'installs trove-guestagent package and service' do
        is_expected.to contain_service('trove-guestagent').with(
          :name      => platform_params[:guestagent_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        is_expected.to contain_package('trove-guestagent').with(
          :name   => platform_params[:guestagent_package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package']
        )
      end

      it 'configures trove-guestagent with default parameters' do
        is_expected.to contain_trove_guestagent_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/use_syslog').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/syslog_log_facility').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/log_file').with_value('/var/log/trove/trove-guestagent.log')
        is_expected.to contain_trove_guestagent_config('DEFAULT/log_dir').with_value('/var/log/trove')
        is_expected.to contain_trove_guestagent_config('DEFAULT/os_region_name').with_value('RegionOne')
        is_expected.to contain_trove_guestagent_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_guestagent_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_hosts').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_userid').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/root_grant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/root_grant_option').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/default_password_length').with_value('<SERVICE DEFAULT>')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-guestagent with RabbitMQ' do
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
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
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('true')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-guestagent with RabbitMQ' do
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
          is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
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
          :swift_url => "http://10.0.0.1:8080/v1/AUTH_",
          :rabbit_host => '10.1.0.1',
          :rabbit_port => '5673',
          :rabbit_use_ssl => 'true'
        }
      end
      it 'configures trove-guestagent with custom parameters' do
        is_expected.to contain_trove_guestagent_config('DEFAULT/trove_auth_url').with_value('http://10.0.0.1:5000/v2.0')
        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_url').with_value('http://10.0.0.1:8080/v1/AUTH_')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_host').with_value('10.1.0.1')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_port').with_value('5673')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
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
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with SSL enabled without kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => true}"
      end

      it do
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with SSL disabled' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => false}"
      end

      it do
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with transport_url entries' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           default_transport_url => 'rabbit://rabbit_user:password@localhost:5673',
           notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673' }"
      end

      it do
        is_expected.to contain_trove_guestagent_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp rpc' do
      let :pre_condition do
        "class { 'trove' :
           nova_proxy_admin_pass => 'verysecrete',
           rpc_backend => 'amqp' }"
      end

      it do
        is_expected.to contain_trove_guestagent_config('DEFAULT/rpc_backend').with_value('amqp')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'Debian',
        :processorcount => 8
      })
    end

    let :platform_params do
      { :guestagent_package_name => 'trove-guestagent',
        :guestagent_service_name => 'trove-guestagent' }
    end

    it_configures 'trove-guestagent'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'RedHat',
        :processorcount => 8
      })
    end

    let :platform_params do
      { :guestagent_package_name => 'openstack-trove-guestagent',
        :guestagent_service_name => 'openstack-trove-guestagent' }
    end

    it_configures 'trove-guestagent'
  end

end
