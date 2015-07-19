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
         nova_proxy_admin_pass => 'verysecrete'}"
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
          :notify => 'Service[trove-taskmanager]'
        )
      end

      it 'configures trove-taskmanager with default parameters' do
        is_expected.to contain_trove_taskmanager_config('DEFAULT/verbose').with_value(false)
        is_expected.to contain_trove_taskmanager_config('DEFAULT/debug').with_value(false)
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        is_expected.to contain_trove_taskmanager_config('DEFAULT/default_neutron_networks').with_value(nil)
        is_expected.to contain_trove_config('DEFAULT/default_neutron_networks').with_value(nil)
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_host').with_value('10.0.0.1')
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
        end
      end

      context 'when using qpid' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rpc_backend           => 'trove.openstack.common.rpc.impl_qpid',
             qpid_hostname         => '10.0.0.1',
             qpid_username         => 'guest',
             qpid_password         => 'password'}"
        end
        it 'configures trove-taskmanager with qpid' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/rpc_backend').with_value('trove.openstack.common.rpc.impl_qpid')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_hostname').with_value('10.0.0.1')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_username').with_value('guest')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_password').with_value('password')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_protocol').with_value('tcp')
        end
      end

      context 'when using qpid with SSL enabled' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rpc_backend           => 'trove.openstack.common.rpc.impl_qpid',
             qpid_hostname         => '10.0.0.1',
             qpid_username         => 'guest',
             qpid_password         => 'password',
             qpid_protocol         => 'ssl'}"
        end
        it 'configures trove-taskmanager with qpid' do
          is_expected.to contain_trove_taskmanager_config('DEFAULT/rpc_backend').with_value('trove.openstack.common.rpc.impl_qpid')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_hostname').with_value('10.0.0.1')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_username').with_value('guest')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_password').with_value('password')
          is_expected.to contain_trove_taskmanager_config('oslo_messaging_qpid/qpid_protocol').with_value('ssl')
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
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
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
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_ensure('absent')
        is_expected.to contain_trove_taskmanager_config('oslo_messaging_rabbit/kombu_ssl_version').with_ensure('absent')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => 8 }
    end

    let :platform_params do
      { :taskmanager_package_name => 'trove-taskmanager',
        :taskmanager_service_name => 'trove-taskmanager' }
    end

    it_configures 'trove-taskmanager'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => 8 }
    end

    let :platform_params do
      { :taskmanager_package_name => 'openstack-trove-taskmanager',
        :taskmanager_service_name => 'openstack-trove-taskmanager' }
    end

    it_configures 'trove-taskmanager'
  end

end
