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
# Unit tests for trove::api
#
require 'spec_helper'

describe 'trove::api' do

  let :params do
    {}
  end

  shared_examples 'trove-api' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
           nova_compute_service_type  => 'compute',
           cinder_service_type        => 'volume',
           swift_service_type         => 'object-store',
           neutron_service_type       => 'network',
           glance_service_type        => 'image',
           nova_compute_endpoint_type => '<SERVICE DEFAULT>',
           cinder_endpoint_type       => '<SERVICE DEFAULT>',
           swift_endpoint_type        => '<SERVICE DEFAULT>',
           trove_endpoint_type        => '<SERVICE DEFAULT>',
           glance_endpoint_type       => '<SERVICE DEFAULT>',
           neutron_endpoint_type      => '<SERVICE DEFAULT>',
         }
         class { 'trove::api::service_credentials':
           password => 'verysectrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it 'includes required classes' do
        is_expected.to contain_class('trove::deps')
        is_expected.to contain_class('trove::db')
        is_expected.to contain_class('trove::db::sync')
        is_expected.to contain_class('trove::params')
        is_expected.to contain_class('trove::api::service_credentials')
      end

      it 'installs trove-api package and service' do
        is_expected.to contain_service('trove-api').with(
          :name      => platform_params[:api_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        is_expected.to contain_package('trove-api').with(
          :name   => platform_params[:api_package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package'],
        )
      end

      it 'configures trove-api with default parameters' do
        is_expected.to contain_trove_config('DEFAULT/bind_host').with_value('0.0.0.0')
        is_expected.to contain_trove_config('DEFAULT/bind_port').with_value('8779')
        is_expected.to contain_trove_config('DEFAULT/backlog').with_value('4096')
        is_expected.to contain_trove_config('DEFAULT/trove_api_workers').with_value('8')
        is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_service_type').with_value('compute')
        is_expected.to contain_trove_config('DEFAULT/cinder_service_type').with_value('volume')
        is_expected.to contain_trove_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_trove_config('DEFAULT/neutron_service_type').with_value('network')
        is_expected.to contain_trove_config('DEFAULT/glance_service_type').with_value('image')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/cinder_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/swift_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/trove_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/neutron_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/glance_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/http_get_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_post_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_put_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_delete_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_mgmt_post_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/taskmanager_queue').with_value('taskmanager')
        is_expected.to contain_trove_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_config('DEFAULT/remote_nova_client').with_ensure('absent')
        is_expected.to contain_trove_config('DEFAULT/remote_cinder_client').with_ensure('absent')
        is_expected.to contain_trove_config('DEFAULT/remote_neutron_client').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('ssl/cert_file').with_ensure('absent')
        is_expected.to contain_trove_config('ssl/key_file').with_ensure('absent')
        is_expected.to contain_trove_config('ssl/ca_file').with_ensure('absent')
        is_expected.to contain_oslo__messaging__rabbit('trove_config').with(
          :rabbit_use_ssl => '<SERVICE DEFAULT>',
        )
      end

      context 'with SSL enabled on API' do
      before :each do
        params.merge!(
          :cert_file => 'cert',
          :key_file  => 'key',
          :ca_file   => 'ca',
        )
        end

        it 'contains ssl parameters' do
          is_expected.to contain_trove_config('ssl/cert_file').with_value('cert')
          is_expected.to contain_trove_config('ssl/key_file').with_value('key')
          is_expected.to contain_trove_config('ssl/ca_file').with_value('ca')
        end
      end

      context 'with overridden rate limit parameters' do
      before :each do
        params.merge!(
          :http_get_rate       => '1000',
          :http_post_rate      => '1000',
          :http_put_rate       => '1000',
          :http_delete_rate    => '1000',
          :http_mgmt_post_rate => '2000',
        )
        end

        it 'contains overrided rate limit values' do
          is_expected.to contain_trove_config('DEFAULT/http_get_rate').with_value('1000')
          is_expected.to contain_trove_config('DEFAULT/http_post_rate').with_value('1000')
          is_expected.to contain_trove_config('DEFAULT/http_put_rate').with_value('1000')
          is_expected.to contain_trove_config('DEFAULT/http_delete_rate').with_value('1000')
          is_expected.to contain_trove_config('DEFAULT/http_mgmt_post_rate').with_value('2000')
        end
      end

      context 'with single tenant mode enabled' do
        let :pre_condition do
          "class { 'trove':
             single_tenant_mode => 'true'
           }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end
        it 'single tenant client values are set' do
          is_expected.to contain_trove_config('DEFAULT/remote_nova_client').with_value('trove.common.single_tenant_remote.nova_client_trove_admin')
          is_expected.to contain_trove_config('DEFAULT/remote_cinder_client').with_value('trove.common.single_tenant_remote.cinder_client_trove_admin')
          is_expected.to contain_trove_config('DEFAULT/remote_neutron_client').with_value('trove.common.single_tenant_remote.neutron_client_trove_admin')
        end
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove': }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        end
      end

      context 'when using a single RabbitMQ server with enable ha options' do
        let :pre_condition do
          "class { 'trove':
             rabbit_ha_queues    => 'true',
             amqp_durable_queues => 'true',
           }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('true')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             rabbit_ha_queues => 'true',
           }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
        end
      end

      context 'when using Neutron' do
        let :pre_condition do
          "class { 'trove':
             use_neutron              => true,
             default_neutron_networks => 'trove_service',
           }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end

        it 'configures trove to use the Neutron network driver' do
          is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_value('trove_service')
          is_expected.to contain_trove_config('DEFAULT/network_driver').with_value('trove.network.neutron.NeutronDriver')
        end

        it 'configures trove to use any network label' do
          is_expected.to contain_trove_config('DEFAULT/network_label_regex').with_value('.*')
        end
      end

      context 'when using Nova Network' do
        let :pre_condition do
          "class { 'trove':
             use_neutron => false
           }
           class { 'trove::api::service_credentials':
             password => 'verysecrete',
           }
           class { 'trove::keystone::authtoken':
             password => 'a_big_secret',
           }"
        end

        it 'configures trove to use the Nova Network network driver' do
          is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_ensure('absent')
          is_expected.to contain_trove_config('DEFAULT/network_driver').with_value('trove.network.nova.NovaNetwork')
        end

        it 'configures trove to use the "private" network label' do
          is_expected.to contain_trove_config('DEFAULT/network_label_regex').with_value('^private$')
        end
      end

    end

    context 'with SSL enabled with kombu' do
      let :pre_condition do
        "class { 'trove':
           rabbit_use_ssl     => true,
           kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
           kombu_ssl_certfile => '/path/to/ssl/cert/file',
           kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
           kombu_ssl_version  => 'TLSv1'
         }
         class { 'trove::api::service_credentials':
           password => 'verysecrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_config').with(
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
         class { 'trove::api::service_credentials':
           password => 'verysecrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_config').with(
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
         class { 'trove::api::service_credentials':
           password => 'verysecrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it do
        is_expected.to contain_oslo__messaging__rabbit('trove_config').with(
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
           rpc_response_timeout       => '120',
           control_exchange           => 'openstack',
           notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673'
         }
         class { 'trove::api::service_credentials':
           password => 'verysecrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it do
        is_expected.to contain_trove_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_config('DEFAULT/rpc_response_timeout').with_value('120')
        is_expected.to contain_trove_config('DEFAULT/control_exchange').with_value('openstack')
        is_expected.to contain_trove_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp rpc' do
      let :pre_condition do
        "class { 'trove': }
         class { 'trove::api::service_credentials':
           password => 'verysecrete',
         }
         class { 'trove::keystone::authtoken':
           password => 'a_big_secret',
         }"
      end

      it do
        is_expected.to contain_trove_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
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
          { :api_package_name => 'trove-api',
            :api_service_name => 'trove-api' }
        when 'RedHat'
          { :api_package_name => 'openstack-trove-api',
            :api_service_name => 'openstack-trove-api' }
        end
      end
      it_configures 'trove-api'
    end
  end

end
