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

  shared_examples_for 'trove' do

    context 'with default parameters' do
      it 'configures the default values' do
        is_expected.to contain_class('trove::params')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/cinder_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/swift_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/neutron_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/glance_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/cinder_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/swift_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/neutron_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/glance_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/cinder_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/swift_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/trove_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/neutron_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/glance_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/management_networks').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('network/network_isolation').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/trove_volume_support').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/volume_rootdisk_support').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/volume_rootdisk_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__messaging__default('trove_config').with(
          :transport_url        => '<SERVICE DEFAULT>',
          :rpc_response_timeout => '<SERVICE DEFAULT>',
          :control_exchange     => 'trove'
        )
        is_expected.to contain_oslo__messaging__rabbit('trove_config').with(
          :rabbit_ha_queues                => '<SERVICE DEFAULT>',
          :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
          :heartbeat_rate                  => '<SERVICE DEFAULT>',
          :heartbeat_in_pthread            => '<SERVICE DEFAULT>',
          :rabbit_qos_prefetch_count       => '<SERVICE DEFAULT>',
          :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
          :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
          :kombu_failover_strategy         => '<SERVICE DEFAULT>',
          :amqp_durable_queues             => '<SERVICE DEFAULT>',
          :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
          :kombu_ssl_version               => '<SERVICE DEFAULT>',
          :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
          :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
          :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
        )
        is_expected.to contain_oslo__messaging__notifications('trove_config').with(
          :transport_url => '<SERVICE DEFAULT>',
          :driver        => '<SERVICE DEFAULT>',
          :topics        => '<SERVICE DEFAULT>'
        )
      end

      it 'installs common package' do
        is_expected.to contain_package('trove').with(
          :name   => platform_params[:package_name],
          :ensure => 'present',
          :tag    => ['openstack', 'trove-package'],
        )
      end

      it 'configures trove to use the Neutron network driver' do
        is_expected.to contain_trove_config('DEFAULT/network_label_regex').with_value('.*')
        is_expected.to contain_trove_config('DEFAULT/network_driver').with_value('trove.network.neutron.NeutronDriver')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :nova_compute_url          => 'http://localhost:8774/v2',
          :cinder_url                => 'http://localhost:8776/v1',
          :swift_url                 => 'http://localhost:8080/v1/AUTH_',
          :neutron_url               => 'http://localhost:9696',
          :glance_url                => 'http://localhost:9292',
          :nova_compute_service_type => 'compute',
          :cinder_service_type       => 'volumev3',
          :swift_service_type        => 'object-store',
          :neutron_service_type      => 'network',
          :glance_service_type       => 'image',
          :network_isolation         => true,
          :trove_volume_support      => true,
          :volume_rootdisk_support   => true,
          :volume_rootdisk_size      => 10,
        }
      end

      it 'configures the given values' do
        is_expected.to contain_trove_config('DEFAULT/nova_compute_url').with_value('http://localhost:8774/v2')
        is_expected.to contain_trove_config('DEFAULT/cinder_url').with_value('http://localhost:8776/v1')
        is_expected.to contain_trove_config('DEFAULT/swift_url').with_value('http://localhost:8080/v1/AUTH_')
        is_expected.to contain_trove_config('DEFAULT/neutron_url').with_value('http://localhost:9696')
        is_expected.to contain_trove_config('DEFAULT/glance_url').with_value('http://localhost:9292')
        is_expected.to contain_trove_config('DEFAULT/nova_compute_service_type').with_value('compute')
        is_expected.to contain_trove_config('DEFAULT/cinder_service_type').with_value('volumev3')
        is_expected.to contain_trove_config('DEFAULT/swift_service_type').with_value('object-store')
        is_expected.to contain_trove_config('DEFAULT/neutron_service_type').with_value('network')
        is_expected.to contain_trove_config('DEFAULT/glance_service_type').with_value('image')
        is_expected.to contain_trove_config('network/network_isolation').with_value(true)
        is_expected.to contain_trove_config('DEFAULT/trove_volume_support').with_value(true)
        is_expected.to contain_trove_config('DEFAULT/volume_rootdisk_support').with_value(true)
        is_expected.to contain_trove_config('DEFAULT/volume_rootdisk_size').with_value(10)
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
          { :package_name => 'trove-common', }
        when 'RedHat'
          { :package_name => 'openstack-trove', }
        end
      end
      it_configures 'trove'
    end
  end

end
