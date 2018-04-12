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
# Unit tests for trove::client
#

require 'spec_helper'

describe 'trove::client' do

  shared_examples_for 'trove client' do

    context 'with default parameters' do
      it { is_expected.to contain_package('python-troveclient').with(
        'ensure' => 'present',
        'name'   => platform_params[:client_package_name],
      )}
    end

    context 'with package_ensure parameter provided' do
      let :params do
        { :package_ensure => false }
      end
      it { is_expected.to contain_package('python-troveclient').with(
        'ensure' => false,
        'name'   => platform_params[:client_package_name],
      )}
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
        case facts[:osfamily]
        when 'Debian'
          if facts[:os_package_type] == 'debian'
            { :client_package_name => 'python3-troveclient' }
          else
            { :client_package_name => 'python-troveclient' }
          end
        when 'RedHat'
          { :client_package_name => 'python-troveclient' }
        end
      end

      it_configures 'trove client'
    end
  end

end
