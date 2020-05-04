#
# Copyright (C) 2020 Red Hat, Inc.
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
require 'spec_helper'

describe 'trove::taskmanager::service_credentials' do

  shared_examples 'trove::taskmanager::service_credentials' do

    context 'with default parameters' do
      let :params do
        {
          :auth_url => 'http://127.0.0.1:5000/v3',
          :password => 'verysecrete'
        }
      end

      it 'configures service credentials with default parameters' do
        is_expected.to contain_trove_taskmanager_config('service_credentials/auth_url').with_value('http://127.0.0.1:5000/v3')
        is_expected.to contain_trove_taskmanager_config('service_credentials/username').with_value('trove')
        is_expected.to contain_trove_taskmanager_config('service_credentials/password').with_value('verysecrete').with_secret(true)
        is_expected.to contain_trove_taskmanager_config('service_credentials/project_name').with_value('services')
        is_expected.to contain_trove_taskmanager_config('service_credentials/region_name').with_value('RegionOne')
        is_expected.to contain_trove_taskmanager_config('service_credentials/user_domain_name').with_value('Default')
        is_expected.to contain_trove_taskmanager_config('service_credentials/project_domain_name').with_value('Default')
      end
    end

    context 'when overriding defaults' do
      let :params do
        {
          :auth_url            => 'http://127.0.0.1:5000/v3',
          :password            => 'verysecrete',
          :username            => 'trove2',
          :project_name        => 'services2',
          :region_name         => 'RegionTwo',
          :user_domain_name    => 'MyDomain',
          :project_domain_name => 'MyDomain',
        }
      end

      it 'configures service credentials with default parameters' do
        is_expected.to contain_trove_taskmanager_config('service_credentials/auth_url').with_value('http://127.0.0.1:5000/v3')
        is_expected.to contain_trove_taskmanager_config('service_credentials/username').with_value('trove2')
        is_expected.to contain_trove_taskmanager_config('service_credentials/project_name').with_value('services2')
        is_expected.to contain_trove_taskmanager_config('service_credentials/region_name').with_value('RegionTwo')
        is_expected.to contain_trove_taskmanager_config('service_credentials/user_domain_name').with_value('MyDomain')
        is_expected.to contain_trove_taskmanager_config('service_credentials/project_domain_name').with_value('MyDomain')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      it_configures 'trove::taskmanager::service_credentials'
    end
  end

end
