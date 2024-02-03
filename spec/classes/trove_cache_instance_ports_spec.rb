require 'spec_helper'

describe 'trove::cache::instance_ports' do

  shared_examples_for 'trove::cache::instance_ports' do
    context 'with default parameters' do
      it 'contains default values' do
        is_expected.to contain_trove_config('instance_ports_cache/expiration_time').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_config('instance_ports_cache/caching').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with overridden parameters' do
      let :params do
        {
          :expiration_time => 86400,
          :caching         => true
        }
      end
      it 'contains overrided values' do
        is_expected.to contain_trove_config('instance_ports_cache/expiration_time').with_value(86400)
        is_expected.to contain_trove_config('instance_ports_cache/caching').with_value(true)
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

      it_configures 'trove::cache::instance_ports'
    end
  end

end
