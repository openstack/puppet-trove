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

describe 'trove::service_credentials' do

  shared_examples 'trove::service_credentials' do

    let :params do
      {
        :password => 'verysecrete'
      }
    end

    context 'with default parameters' do
      it 'configures service credentials with default parameters' do
        is_expected.to contain_trove_config('service_credentials/auth_url').with_value('http://127.0.0.1:5000')
        is_expected.to contain_trove_config('service_credentials/username').with_value('trove')
        is_expected.to contain_trove_config('service_credentials/password').with_value('verysecrete').with_secret(true)
        is_expected.to contain_trove_config('service_credentials/project_name').with_value('services')
        is_expected.to contain_trove_config('service_credentials/region_name').with_value('RegionOne')
        is_expected.to contain_trove_config('service_credentials/user_domain_name').with_value('Default')
        is_expected.to contain_trove_config('service_credentials/project_domain_name').with_value('Default')
        is_expected.to contain_trove_config('service_credentials/system_scope').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when overriding defaults' do
      before do
        params.merge!({
          :auth_url            => 'http://localhost:5000',
          :username            => 'trove2',
          :project_name        => 'services2',
          :region_name         => 'RegionTwo',
          :user_domain_name    => 'MyDomain',
          :project_domain_name => 'MyDomain',
        })
      end

      it 'configures service credentials with default parameters' do
        is_expected.to contain_trove_config('service_credentials/auth_url').with_value('http://localhost:5000')
        is_expected.to contain_trove_config('service_credentials/username').with_value('trove2')
        is_expected.to contain_trove_config('service_credentials/project_name').with_value('services2')
        is_expected.to contain_trove_config('service_credentials/region_name').with_value('RegionTwo')
        is_expected.to contain_trove_config('service_credentials/user_domain_name').with_value('MyDomain')
        is_expected.to contain_trove_config('service_credentials/project_domain_name').with_value('MyDomain')
        is_expected.to contain_trove_config('service_credentials/system_scope').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'when system_scope is set' do
      before do
        params.merge!(
          :system_scope => 'all'
        )
      end
      it 'configures system-scoped credential' do
        is_expected.to contain_trove_config('service_credentials/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('service_credentials/project_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('service_credentials/system_scope').with_value('all')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts())
    end

    context "on #{os}" do
      it_configures 'trove::service_credentials'
    end
  end

end
