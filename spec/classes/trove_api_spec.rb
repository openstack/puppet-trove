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
        is_expected.to contain_trove_config('DEFAULT/bind_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/bind_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/backlog').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/trove_api_workers').with_value('8')
        is_expected.to contain_trove_config('DEFAULT/http_get_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/http_post_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/http_put_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/http_delete_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/http_mgmt_post_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/taskmanager_queue').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__service__ssl('trove_config').with(
          :cert_file => '<SERVICE DEFAULT>',
          :key_file  => '<SERVICE DEFAULT>',
          :ca_file   => '<SERVICE DEFAULT>'
        )
      end

      context 'with SSL enabled on API' do
        before :each do
          params.merge!(
            :cert_file => '/path/to/cert',
            :key_file  => '/path/to/key',
            :ca_file   => '/path/to/ca',
          )
        end

        it 'contains ssl parameters' do
          is_expected.to contain_oslo__service__ssl('trove_config').with(
            :cert_file => '/path/to/cert',
            :key_file  => '/path/to/key',
            :ca_file   => '/path/to/ca'
          )
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

      context 'with db sync disabled' do
        before :each do
          params.merge!(
            :sync_db => false,
          )
        end

        it 'does not run db sync' do
          is_expected.to_not contain_class('trove::db::sync')
        end
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
        case facts[:os]['family']
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
