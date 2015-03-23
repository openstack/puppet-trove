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
# Unit tests for trove::keystone::auth
#

require 'spec_helper'

describe 'trove::keystone::auth' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  describe 'with default class parameters' do
    let :params do
      { :password => 'trove_password',
        :tenant   => 'foobar' }
    end

    it { is_expected.to contain_keystone_user('trove').with(
      :ensure   => 'present',
      :password => 'trove_password',
      :tenant   => 'foobar'
    ) }

    it { is_expected.to contain_keystone_user_role('trove@foobar').with(
      :ensure  => 'present',
      :roles   => 'admin'
    )}

    it { is_expected.to contain_keystone_service('trove').with(
      :ensure      => 'present',
      :type        => 'database',
      :description => 'Trove Database Service'
    ) }

    it { is_expected.to contain_keystone_endpoint('RegionOne/trove').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:8779/v1.0/\$(tenant_id)s",
      :admin_url    => "http://127.0.0.1:8779/v1.0/\$(tenant_id)s",
      :internal_url => "http://127.0.0.1:8779/v1.0/\$(tenant_id)s"
    ) }
  end

  describe 'when configuring trove-server' do
    let :pre_condition do
      "class { 'trove::server': auth_password => 'test' }"
    end

    let :params do
      { :password => 'trove_password',
        :tenant   => 'foobar' }
    end
  end

  describe 'when overriding public_protocol, public_port and public address' do
    let :params do
      { :password         => 'trove_password',
        :public_protocol  => 'https',
        :public_port      => '80',
        :public_address   => '10.10.10.10',
        :port             => '81',
        :internal_address => '10.10.10.11',
        :admin_address    => '10.10.10.12' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/trove').with(
      :ensure       => 'present',
      :public_url   => "https://10.10.10.10:80/v1.0/\$(tenant_id)s",
      :internal_url => "http://10.10.10.11:81/v1.0/\$(tenant_id)s",
      :admin_url    => "http://10.10.10.12:81/v1.0/\$(tenant_id)s"
    ) }
  end

  describe 'when overriding auth name' do
    let :params do
      { :password => 'foo',
        :auth_name => 'trovey' }
    end

    it { is_expected.to contain_keystone_user('trovey') }
    it { is_expected.to contain_keystone_user_role('trovey@services') }
    it { is_expected.to contain_keystone_service('trovey') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/trovey') }
  end

  describe 'when overriding service name' do
    let :params do
      { :service_name => 'trove_service',
        :auth_name    => 'trove',
        :password     => 'trove_password' }
    end

    it { is_expected.to contain_keystone_user('trove') }
    it { is_expected.to contain_keystone_user_role('trove@services') }
    it { is_expected.to contain_keystone_service('trove_service') }
    it { is_expected.to contain_keystone_endpoint('RegionOne/trove_service') }
  end

end
