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
    { :keystone_password     => 'passw0rd',
      :auth_host             => '10.0.0.10',
      :auth_url              => 'http://10.0.0.10:5000/v2.0',
      :auth_port             => '35357',
      :auth_protocol         => 'https',
      :keystone_tenant       => '_services_',
      :keystone_user         => 'trove',
    }
  end

  shared_examples 'trove-api' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass => 'verysecrete'}"
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
          :notify => 'Service[trove-api]'
        )
      end

      it 'configures trove-api with default parameters' do
        is_expected.to contain_trove_config('DEFAULT/verbose').with_value(false)
        is_expected.to contain_trove_config('DEFAULT/debug').with_value(false)
        is_expected.to contain_trove_config('DEFAULT/bind_host').with_value('0.0.0.0')
        is_expected.to contain_trove_config('DEFAULT/bind_port').with_value('8779')
        is_expected.to contain_trove_config('DEFAULT/backlog').with_value('4096')
        is_expected.to contain_trove_config('DEFAULT/trove_api_workers').with_value('8')
        is_expected.to contain_trove_config('DEFAULT/trove_auth_url').with_value('http://10.0.0.10:5000/v2.0')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_config('keystone_authtoken/auth_host').with_value('10.0.0.10')
        is_expected.to contain_trove_config('keystone_authtoken/auth_port').with_value('35357')
        is_expected.to contain_trove_config('keystone_authtoken/auth_protocol').with_value('https')
        is_expected.to contain_trove_config('keystone_authtoken/admin_tenant_name').with_value('_services_')
        is_expected.to contain_trove_config('keystone_authtoken/admin_user').with_value('trove')
        is_expected.to contain_trove_config('keystone_authtoken/admin_password').with_value('passw0rd')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
        end
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             database_connection   => 'mysql://trove:pass@10.0.0.1/trove'}"
        end
        it 'configures trove-api with RabbitMQ' do
          is_expected.to contain_trove_config('database/connection').with_value('mysql://trove:pass@10.0.0.1/trove')
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
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
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
        is_expected.to contain_trove_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => 8 }
    end

    let :platform_params do
      { :api_package_name => 'trove-api',
        :api_service_name => 'trove-api' }
    end

    it_configures 'trove-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => 8 }
    end

    let :platform_params do
      { :api_package_name => 'openstack-trove-api',
        :api_service_name => 'openstack-trove-api' }
    end

    it_configures 'trove-api'
  end

end
