require 'spec_helper'

describe 'trove::quota' do

  shared_examples_for 'trove::quota' do
    context 'with default parameters' do
      it 'contains default values' do
        is_expected.to contain_trove_config('DEFAULT/max_instances_per_tenant').with(
          :value => 5)
        is_expected.to contain_trove_config('DEFAULT/max_ram_per_tenant').with(
          :value => -1)
        is_expected.to contain_trove_config('DEFAULT/max_accepted_volume_size').with(
          :value => 5)
        is_expected.to contain_trove_config('DEFAULT/max_volumes_per_tenant').with(
          :value => 20)
        is_expected.to contain_trove_config('DEFAULT/max_backups_per_tenant').with(
          :value => 50)
        is_expected.to contain_trove_config('DEFAULT/quota_driver').with(
          :value => 'trove.quota.quota.DbQuotaDriver')
      end
    end

    context 'with overridden parameters' do
      let :params do
        { :max_instances_per_tenant => 10,
          :max_ram_per_tenant       => 10,
          :max_accepted_volume_size => 10,
          :max_volumes_per_tenant   => 100,
          :max_backups_per_tenant   => 100,
        }
      end
      it 'contains overrided values' do
        is_expected.to contain_trove_config('DEFAULT/max_instances_per_tenant').with(
          :value => 10)
        is_expected.to contain_trove_config('DEFAULT/max_ram_per_tenant').with(
          :value => 10)
        is_expected.to contain_trove_config('DEFAULT/max_accepted_volume_size').with(
          :value => 10)
        is_expected.to contain_trove_config('DEFAULT/max_volumes_per_tenant').with(
          :value => 100)
        is_expected.to contain_trove_config('DEFAULT/max_backups_per_tenant').with(
          :value => 100)
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
