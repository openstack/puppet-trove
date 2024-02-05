require 'spec_helper'

describe 'trove::quota' do

  shared_examples_for 'trove::quota' do
    context 'with default parameters' do
      it 'contains default values' do
        is_expected.to contain_trove_config('DEFAULT/max_instances_per_tenant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/max_ram_per_tenant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/max_accepted_volume_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/max_volumes_per_tenant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/max_backups_per_tenant').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('DEFAULT/quota_driver').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with overridden parameters' do
      let :params do
        { :max_instances_per_tenant => 10,
          :max_ram_per_tenant       => 10,
          :max_accepted_volume_size => 10,
          :max_volumes_per_tenant   => 100,
          :max_backups_per_tenant   => 100,
          :quota_driver             => 'trove.quota.quota.DbQuotaDriver',
        }
      end
      it 'contains overrided values' do
        is_expected.to contain_trove_config('DEFAULT/max_instances_per_tenant').with_value(10)
        is_expected.to contain_trove_config('DEFAULT/max_ram_per_tenant').with_value(10)
        is_expected.to contain_trove_config('DEFAULT/max_accepted_volume_size').with_value(10)
        is_expected.to contain_trove_config('DEFAULT/max_volumes_per_tenant').with_value(100)
        is_expected.to contain_trove_config('DEFAULT/max_backups_per_tenant').with_value(100)
        is_expected.to contain_trove_config('DEFAULT/quota_driver').with_value('trove.quota.quota.DbQuotaDriver')
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

      it_configures 'trove::quota'
    end
  end

end
