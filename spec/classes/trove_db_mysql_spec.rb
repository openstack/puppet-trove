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

require 'spec_helper'

describe 'trove::db::mysql' do

  let :pre_condition do
    [
      'include mysql::server',
      'include trove::db::sync'
    ]
  end

  let :default_params do
    {
      'dbname'        => 'trove',
      'user'          => 'trove',
      'charset'       => 'utf8',
      'collate'       => 'utf8_unicode_ci',
      'host'          => '127.0.0.1',
      'allowed_hosts' => ['127.0.0.%', '192.168.1.%']
    }
  end

  let :params do
    { :password => 'passw0rd' }
  end

  shared_examples_for 'trove db mysql' do

    let :p do
      default_params.merge(params)
    end

    it { should contain_class('mysql::python') }

    it { should contain_mysql__db(p['dbname']).with(
      'user'     => p['user'],
      'password' => 'passw0rd',
      'host'     => p['host'],
      'charset'  => p['charset'],
      'require'  => 'Class[Mysql::Config]'
    )}

    context 'overriding allowed_hosts param to array' do
      before :each do
        params.merge!(
          :password       => 'trovepass',
          :allowed_hosts  => ['127.0.0.1','%']
        )
      end

      it {should_not contain_trove__db__mysql__host_access("127.0.0.1").with(
        :user     => 'trove',
        :password => 'trovepass',
        :database => 'trove'
      )}
      it {should contain_trove__db__mysql__host_access("%").with(
        :user     => 'trove',
        :password => 'trovepass',
        :database => 'trove'
      )}
    end

    context 'overriding allowed_hosts param to string' do
      before :each do
        params.merge!(
          :password       => 'trovepass2',
          :allowed_hosts  => '192.168.1.1'
        )
      end

      it {should contain_trove__db__mysql__host_access("192.168.1.1").with(
        :user     => 'trove',
        :password => 'trovepass2',
        :database => 'trove'
      )}
    end

    context 'overriding allowed_hosts param equals to host param ' do
      before :each do
        params.merge!(
          :password       => 'trovepass2',
          :allowed_hosts  => '127.0.0.1'
        )
      end

      it {should_not contain_trove__db__mysql__host_access("127.0.0.1").with(
        :user     => 'trove',
        :password => 'trovepass2',
        :database => 'trove'
      )}
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'trove db mysql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'trove db mysql'
  end
end
