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
        should contain_service('trove-taskmanager').with(
          :name      => platform_params[:taskmanager_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        should contain_package('trove-taskmanager').with(
          :name   => platform_params[:taskmanager_package_name],
          :ensure => 'present',
          :notify => 'Service[trove-taskmanager]'
        )
      end

      it 'configures trove-taskmanager with default parameters' do
        should contain_trove_taskmanager_config('DEFAULT/verbose').with_value(false)
        should contain_trove_taskmanager_config('DEFAULT/debug').with_value(false)
        should contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        should contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        should contain_trove_taskmanager_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          should contain_trove_taskmanager_config('DEFAULT/rabbit_host').with_value('10.0.0.1')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          should contain_trove_taskmanager_config('DEFAULT/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
        end
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             database_connection   => 'mysql://trove:pass@10.0.0.1/trove'}"
        end
        it 'configures trove-taskmanager with RabbitMQ' do
          should contain_trove_taskmanager_config('DEFAULT/sql_connection').with_value('mysql://trove:pass@10.0.0.1/trove')
        end
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
