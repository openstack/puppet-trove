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

  let :params do
    { :dbname   => 'trove',
      :password => 'trovepass',
      :user     => 'trove',
      :charset  => 'utf8',
      :collate  => 'utf8_general_ci',
      :host     => '127.0.0.1',
    }
  end

  shared_examples_for 'trove mysql database' do
    it { should contain_class('trove::deps') }

    context 'when omiting the required parameter password' do
      before { params.delete(:password) }
      it { is_expected.to raise_error(Puppet::Error) }
    end

    it 'creates a mysql database' do
      is_expected.to contain_openstacklib__db__mysql('trove').with(
        :user          => params[:user],
        :dbname        => params[:dbname],
        :password      => params[:password],
        :host          => params[:host],
        :charset       => params[:charset]
      )
    end

    context 'overriding allowed_hosts param to array' do
      before :each do
        params.merge!(
          :allowed_hosts => ['127.0.0.1','%']
        )
      end

      it {
        is_expected.to contain_openstacklib__db__mysql('trove').with(
          :user          => params[:user],
          :dbname        => params[:dbname],
          :password      => params[:password],
          :host          => params[:host],
          :charset       => params[:charset],
          :allowed_hosts => ['127.0.0.1','%']
      )}
    end

    context 'overriding allowed_hosts param to string' do
      before :each do
        params.merge!(
          :allowed_hosts  => '192.168.1.1'
        )
      end

      it {
        is_expected.to contain_openstacklib__db__mysql('trove').with(
          :user          => params[:user],
          :dbname        => params[:dbname],
          :password      => params[:password],
          :host          => params[:host],
          :charset       => params[:charset],
          :allowed_hosts => '192.168.1.1'
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

      it_configures 'trove mysql database'
    end
  end

end
