require 'spec_helper'

describe 'trove::guestagent' do

  shared_examples 'trove-guestagent' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it 'includes required classes' do
        is_expected.to contain_class('trove::deps')
        is_expected.to contain_class('trove::params')
        is_expected.to contain_class('trove::guestagent::service_credentials')
      end

      it 'installs trove-guestagent package and service' do
        is_expected.to contain_service('trove-guestagent').with(
          :name      => platform_params[:guestagent_service_name],
          :ensure    => 'stopped',
          :hasstatus => true,
          :enable    => false
        )
        is_expected.to contain_package('trove-guestagent').with(
          :name   => platform_params[:guestagent_package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package']
        )
      end

      it 'configures trove-guestagent with default parameters' do
        is_expected.to contain_oslo__messaging__default('trove_guestagent_config').with(
          :transport_url        => '<SERVICE DEFAULT>',
          :control_exchange     => 'trove',
          :rpc_response_timeout => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_oslo__messaging__notifications('trove_guestagent_config').with(
          :transport_url => '<SERVICE DEFAULT>',
          :driver        => '<SERVICE DEFAULT>',
          :topics        => '<SERVICE DEFAULT>',
          :retry         => '<SERVICE DEFAULT>',
        )
 
        is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
          :rabbit_ha_queues                => '<SERVICE DEFAULT>',
          :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
          :heartbeat_rate                  => '<SERVICE DEFAULT>',
          :heartbeat_in_pthread            => '<SERVICE DEFAULT>',
          :rabbit_qos_prefetch_count       => '<SERVICE DEFAULT>',
          :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
          :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
          :kombu_failover_strategy         => '<SERVICE DEFAULT>',
          :amqp_durable_queues             => '<SERVICE DEFAULT>',
          :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
          :kombu_ssl_version               => '<SERVICE DEFAULT>',
          :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
          :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
          :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
          :enable_cancel_on_failover       => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/root_grant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/root_grant_option').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/default_password_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/backup_aes_cbc_key').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('guest_agent/container_registry').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('guest_agent/container_registry_username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('guest_agent/container_registry_password').with_value('<SERVICE DEFAULT>').with_secret(true)
        is_expected.to contain_trove_guestagent_config('DEFAULT/num_tries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/volume_fstype').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/format_options').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/volume_format_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('DEFAULT/mount_options').with_value('<SERVICE DEFAULT>')
      end

      it 'configures trove-guestagent with default logging parameters' do
        is_expected.to contain_oslo__log('trove_guestagent_config').with(
          :use_syslog          => '<SERVICE DEFAULT>',
          :syslog_log_facility => '<SERVICE DEFAULT>',
          :log_dir             => '/var/log/trove',
          :log_file            => '/var/log/trove/trove-guestagent.log',
          :debug               => '<SERVICE DEFAULT>',
        )
      end

      context 'with custom rabbitmq parameters' do
        let :pre_condition do
          "class { 'trove':
             rabbit_ha_queues            => 'true',
             rabbit_heartbeat_in_pthread => 'true',
             amqp_durable_queues         => 'true',
           }
           class { 'trove::guestagent::service_credentials':
             password => 'verysectrete',
           }"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
            :rabbit_ha_queues        => true,
            :heartbeat_in_pthread    => true,
            :amqp_durable_queues     => true,
          )
        end
      end

      context 'with custom messaging default parameters' do
        let :pre_condition do
          "class { 'trove':
             default_transport_url => 'rabbit://user:pass@host:1234/virt',
             rpc_response_timeout  => '120',
             control_exchange      => 'openstack',
           }
           class { 'trove::guestagent::service_credentials':
             password => 'verysectrete',
           }"
        end

        it 'configures trove-guestagent with messaging default parameters' do
          is_expected.to contain_oslo__messaging__default('trove_guestagent_config').with(
            :transport_url        => 'rabbit://user:pass@host:1234/virt',
            :control_exchange     => 'openstack',
            :rpc_response_timeout => '120',
          )
        end
      end
    end

    context 'with custom parameters' do
      let :pre_condition do
        "class { 'trove': }
         class { 'trove::guestagent::service_credentials':
          password => 'verysectrete',
         }"
      end

      let :params do
        {
          :swift_url          => 'http://10.0.0.1:8080/v1/AUTH_',
          :swift_service_type => 'object-store',
          :rabbit_use_ssl     => 'true'
        }
      end
      it 'configures trove-guestagent with custom parameters' do
        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_url').with_value('http://10.0.0.1:8080/v1/AUTH_')
        is_expected.to contain_trove_guestagent_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
          :rabbit_use_ssl => 'true',
        )
      end
    end

    context 'with SSL enabled with kombu' do
      let :pre_condition do
        "class { 'trove':
           rabbit_use_ssl     => true,
           kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
           kombu_ssl_certfile => '/path/to/ssl/cert/file',
           kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
           kombu_ssl_version  => 'TLSv1'}
         class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
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
           rabbit_use_ssl => true
         }
         class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
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
           rabbit_use_ssl => false
         }
         class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_guestagent_config').with(
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
           default_transport_url      => 'rabbit://rabbit_user:password@localhost:5673',
           notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673'
         }
         class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__default('trove_guestagent_config').with(
          :transport_url => 'rabbit://rabbit_user:password@localhost:5673',
        )
        is_expected.to contain_oslo__messaging__notifications('trove_guestagent_config').with(
          :transport_url => 'rabbit://rabbit_user:password@localhost:5673',
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :guestagent_package_name => 'trove-guestagent',
            :guestagent_service_name => 'trove-guestagent' }
        when 'RedHat'
          { :guestagent_package_name => 'openstack-trove-guestagent',
            :guestagent_service_name => 'openstack-trove-guestagent' }
        end
      end
      it_configures 'trove-guestagent'
    end
  end

end
