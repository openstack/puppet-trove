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
    { :keystone_password => 'passw0rd',
      :identity_uri      => 'http://10.0.0.10:35357/',
      :auth_uri          => 'http://10.0.0.10:5000/v2.0/',
      :keystone_tenant   => '_services_',
      :keystone_user     => 'trove',
    }
  end

  shared_examples 'trove-api' do

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
        is_expected.to contain_trove_config('DEFAULT/trove_auth_url').with_value('http://10.0.0.10:5000/v2.0/')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_config('keystone_authtoken/auth_uri').with_value('http://10.0.0.10:5000/v2.0/')
        is_expected.to contain_trove_config('keystone_authtoken/auth_url').with_value('http://10.0.0.10:35357/')
        is_expected.to contain_trove_config('keystone_authtoken/project_name').with_value('_services_')
        is_expected.to contain_trove_config('keystone_authtoken/username').with_value('trove')
        is_expected.to contain_trove_config('keystone_authtoken/password').with_value('passw0rd')
        is_expected.to contain_trove_config('DEFAULT/control_exchange').with_value('trove')
        is_expected.to contain_trove_config('DEFAULT/os_region_name').with_value('RegionOne')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_service_type').with_value('compute')
        is_expected.to contain_trove_config('DEFAULT/cinder_service_type').with_value('volume')
        is_expected.to contain_trove_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_trove_config('DEFAULT/heat_service_type').with_value('orchestration')
        is_expected.to contain_trove_config('DEFAULT/neutron_service_type').with_value('network')
        is_expected.to contain_trove_config('DEFAULT/http_get_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_post_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_put_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_delete_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/http_mgmt_post_rate').with_value('200')
        is_expected.to contain_trove_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_notifications/topics').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_userid').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('ssl/cert_file').with_ensure('absent')
        is_expected.to contain_trove_config('ssl/key_file').with_ensure('absent')
        is_expected.to contain_trove_config('ssl/ca_file').with_ensure('absent')
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

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>')
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
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
          is_expected.to contain_trove_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('true')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_ha_queues      => 'true',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
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
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
      end
    end

    context 'with SSL enabled without kombu' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => true}"
      end

      it do
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with SSL disabled' do
      let :pre_condition do
        "class { 'trove':
           nova_proxy_admin_pass => 'verysecrete',
           rabbit_use_ssl     => false}"
      end

      it do
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
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
        is_expected.to contain_trove_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_trove_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      end
    end

    context 'with amqp rpc' do
      let :pre_condition do
        "class { 'trove' :
           nova_proxy_admin_pass => 'verysecrete',
           rpc_backend => 'amqp' }"
      end

      it do
        is_expected.to contain_trove_config('DEFAULT/rpc_backend').with_value('amqp')
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
        is_expected.to contain_trove_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
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
      { :api_package_name => 'trove-api',
        :api_service_name => 'trove-api' }
    end

    it_configures 'trove-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily       => 'RedHat',
        :processorcount => 8,
      })
    end

    let :platform_params do
      { :api_package_name => 'openstack-trove-api',
        :api_service_name => 'openstack-trove-api' }
    end

    it_configures 'trove-api'
  end

end
