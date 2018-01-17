#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for trove::taskmanager
#
require 'spec_helper'

describe 'trove::taskmanager' do

  shared_examples 'trove-taskmanager' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass      => 'verysecrete',
         os_region_name             => 'RegionOne',
         nova_compute_service_type  => 'compute',
         cinder_service_type        => 'volume',
         swift_service_type         => 'object-store',
         neutron_service_type       => 'network',
         nova_compute_endpoint_type => '<SERVICE DEFAULT>',
         cinder_endpoint_type       => '<SERVICE DEFAULT>',
         swift_endpoint_type        => '<SERVICE DEFAULT>',
         trove_endpoint_type        => '<SERVICE DEFAULT>',
         glance_endpoint_type       => '<SERVICE DEFAULT>',
         neutron_endpoint_type      => '<SERVICE DEFAULT>',
         }"
      end

      it 'installs trove-taskmanager package and service' do
        is_expected.to contain_service('trove-taskmanager').with(
          :name      => platform_params[:taskmanager_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        is_expected.to contain_package('trove-taskmanager').with(
          :name   => platform_params[:taskmanager_package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package']
        )
      end

      it 'configures trove-taskmanager with default parameters' do
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/os_region_name').with_value('RegionOne')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_compute_service_type').with_value('compute')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/cinder_service_type').with_value('volume')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/neutron_service_type').with_value('network')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_compute_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/cinder_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/swift_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/trove_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/neutron_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/glance_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/taskmanager_manager').with_value('trove.taskmanager.manager.Manager')
        is_expected.to contain_file('/etc/trove/trove-guestagent.conf')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_nova_client').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_cinder_client').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_neutron_client').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_userid').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__messaging__rabbit('trove_taskmanager_config').with(
          :rabbit_use_ssl => '<SERVICE DEFAULT>',
        )
      end

      it 'configures trove-taskmanager with default logging parameters' do
        is_expected.to contain_oslo__log('trove_taskmanager_config').with(
          :use_syslog          => '<SERVICE DEFAULT>',
          :syslog_log_facility => '<SERVICE DEFAULT>',
          :log_dir             => '/var/log/trove',
          :log_file            => '/var/log/trove/trove-taskmanager.log',
          :debug               => '<SERVICE DEFAULT>',
        )
      end

      context 'when set use_guestagent_template to false' do
        let :pre_condition do
           "class { 'trove':
              nova_proxy_admin_pass => 'verysecrete',}
            class { 'trove::taskmanager':
              use_guestagent_template => false,}"
        end
        it 'configures trove-taskmanager with trove::guestagent' do
          is_expected.to contain_class('trove::guestagent').with(
            :enabled         => false,
            :manage_service  => false,
          )
        end
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
          is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_nova_client').with_value('trove.common.single_tenant_remote.nova_client_trove_admin')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_cinder_client').with_value('trove.common.single_tenant_remote.cinder_client_trove_admin')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/remote_neutron_client').with_value('trove.common.single_tenant_remote.neutron_client_trove_admin')
        end
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')

          # trove taskmanager also configures trove_guestagent.conf by default, ensure rabbit is right there
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^rabbit_host=10.0.0.1$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^#rabbit_port=5672$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^#rabbit_ha_queues=false$/)
        end
      end

      context 'when using a single RabbitMQ server with enable rabbbit ha options' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_ha_queues      => 'true',
             amqp_durable_queues   => 'true',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('true')

          # trove taskmanager also configures trove_guestagent.conf by default, ensure rabbit is right there
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^rabbit_host=10.0.0.1$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^#rabbit_port=5672$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^rabbit_ha_queues=true$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^amqp_durable_queues=true$/)
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')

          # trove taskmanager also configures trove_guestagent.conf by default, ensure rabbit is right there
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^rabbit_hosts=10.0.0.1,10.0.0.2$/)
          is_expected.to contain_file('/etc/trove/trove-guestagent.conf').with_content(/^rabbit_ha_queues=true$/)
        end
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             database_connection   => 'mysql://trove:pass@10.0.0.1/trove'}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          is_expected.to contain_trove_taskmanager_config('database/connection').with_value('mysql://trove:pass@10.0.0.1/trove')
        end
      end

      context 'when using Neutron' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass    => 'verysecrete',
             use_neutron              => true}
           class { 'trove::taskmanager':
             default_neutron_networks => 'trove_service',
           }
          "

        end

        it 'configures trove to use the Neutron network driver' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_value('trove_service')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_driver').with_value('trove.network.neutron.NeutronDriver')

        end

        it 'configures trove to use any network label' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_label_regex').with_value('.*')
        end
      end

      context 'when using Nova Network' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             use_neutron           => false}"

        end

        it 'configures trove to use the Nova Network network driver' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_ensure('absent')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_driver').with_value('trove.network.nova.NovaNetwork')
        end

        it 'configures trove to use the "private" network label' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_label_regex').with_value('^private$')
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
        is_expected.to contain_oslo__messaging__rabbit('trove_taskmanager_config').with(
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
        is_expected.to contain_oslo__messaging__rabbit('trove_taskmanager_config').with(
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
        is_expected.to contain_oslo__messaging__rabbit('trove_taskmanager_config').with(
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
        is_expected.to contain_trove_taskmanager_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/rpc_response_timeout').with_value('120')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/control_exchange').with_value('openstack')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp messaging' do
      let :pre_condition do
        "class { 'trove' :
           nova_proxy_admin_pass => 'verysecrete'}"
      end

      it do
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
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
        case facts[:osfamily]
        when 'Debian'
          { :taskmanager_package_name => 'trove-taskmanager',
            :taskmanager_service_name => 'trove-taskmanager' }
        when 'RedHat'
          { :taskmanager_package_name => 'openstack-trove-taskmanager',
            :taskmanager_service_name => 'openstack-trove-taskmanager' }
        end
      end
      it_configures 'trove-taskmanager'
    end
  end

end
