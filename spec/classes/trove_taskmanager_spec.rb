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
         nova_proxy_admin_pass     => 'verysecrete',
         os_region_name            => 'RegionOne',
         nova_compute_service_type => 'compute',
         cinder_service_type       => 'volume',
         swift_service_type        => 'object-store',
         heat_service_type         => 'orchestration',
         neutron_service_type      => 'network'}"
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
        is_expected.to contain_trove_taskmanager_config('DEFAULT/debug').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/use_syslog').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/syslog_log_facility').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/log_file').with_value('/var/log/trove/trove-taskmanager.log')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/log_dir').with_value('/var/log/trove')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_value(nil)
        is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_value(nil)
        is_expected.to contain_trove_taskmanager_config('DEFAULT/os_region_name').with_value('RegionOne')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_compute_service_type').with_value('compute')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/cinder_service_type').with_value('volume')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/heat_service_type').with_value('orchestration')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/neutron_service_type').with_value('network')
        is_expected.to contain_trove_config('DEFAULT/taskmanager_queue').with_value('taskmanager')
        is_expected.to contain_file('/etc/trove/trove-guestagent.conf')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_userid').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
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
          is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_value('trove_service')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_value('trove_service')
          is_expected.to contain_trove_config('DEFAULT/network_driver').with_value('trove.network.neutron.NeutronDriver')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_driver').with_value('trove.network.neutron.NeutronDriver')

        end

        it 'configures trove to use any network label' do
          is_expected.to contain_trove_config('DEFAULT/network_label_regex').with_value('.*')
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
          is_expected.to contain_trove_config('DEFAULT/network_driver').with_value('trove.network.nova.NovaNetwork')
          is_expected.to contain_trove_taskmanager_config('DEFAULT/network_driver').with_value('trove.network.nova.NovaNetwork')

        end

        it 'configures trove to use the "private" network label' do
          is_expected.to contain_trove_config('DEFAULT/network_label_regex').with_value('^private$')
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
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with SSL enabled without kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => true}"
      end

      it do
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with SSL disabled' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => false}"
      end

      it do
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
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
        is_expected.to contain_trove_taskmanager_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp rpc' do
      let :pre_condition do
        "class { 'trove' :
           nova_proxy_admin_pass => 'verysecrete',
           rpc_backend => 'amqp' }"
      end

      it do
        is_expected.to contain_trove_taskmanager_config('DEFAULT/rpc_backend').with_value('amqp')
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

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'Debian',
        :processorcount => 8
      })
    end

    let :platform_params do
      { :taskmanager_package_name => 'trove-taskmanager',
        :taskmanager_service_name => 'trove-taskmanager' }
    end

    it_configures 'trove-taskmanager'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'RedHat',
        :processorcount => 8
      })
    end

    let :platform_params do
      { :taskmanager_package_name => 'openstack-trove-taskmanager',
        :taskmanager_service_name => 'openstack-trove-taskmanager' }
    end

    it_configures 'trove-taskmanager'
  end

end
