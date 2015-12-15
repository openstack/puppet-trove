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
# Unit tests for trove::init
#

require 'spec_helper'

describe 'trove' do

  let :params do
    { :nova_proxy_admin_pass     => 'passw0rd',
      :nova_compute_url          => 'http://localhost:8774/v2',
      :cinder_url                => 'http://localhost:8776/v1',
      :swift_url                 => 'http://localhost:8080/v1/AUTH_',
      :neutron_url               => 'http://localhost:9696/',
    }
  end

  shared_examples_for 'trove' do

    context 'with default parameters' do
      it {
        is_expected.to contain_class('trove::params')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_url').with_value('http://localhost:8774/v2')
        is_expected.to contain_trove_config('DEFAULT/cinder_url').with_value('http://localhost:8776/v1')
        is_expected.to contain_trove_config('DEFAULT/swift_url').with_value('http://localhost:8080/v1/AUTH_')
        is_expected.to contain_trove_config('DEFAULT/neutron_url').with_value('http://localhost:9696/')
      }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'trove'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it 'installs common package' do
      is_expected.to contain_package('trove').with(
        :name   => 'openstack-trove',
        :ensure => 'present',
        :tag    => ['openstack', 'trove-package'],
      )
    end

    it_configures 'trove'
  end
end
