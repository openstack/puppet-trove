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
        "class { 'trove::guestagent::service_credentials':
           password => 'verysectrete',
         }"
      end

      it 'includes required classes' do
        is_expected.to contain_class('trove::deps')
        is_expected.to contain_class('trove::params')
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
        is_expected.to contain_trove_config('DEFAULT/taskmanager_manager').with_value('trove.taskmanager.manager.Manager')
        is_expected.to contain_trove_config('DEFAULT/guest_config').with_value('/etc/trove/trove-guestagent.conf')
      end

      it 'configures trove-taskmanager with trove::guestagent' do
        is_expected.to contain_class('trove::guestagent')
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
