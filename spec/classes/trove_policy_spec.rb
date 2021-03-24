require 'spec_helper'

describe 'trove::policy' do
  shared_examples 'trove::policy' do
    let :params do
      {
        :enforce_scope => false,
        :policy_path   => '/etc/trove/policy.yaml',
        :policies      => {
          'context_is_admin' => {
            'key'   => 'context_is_admin',
            'value' => 'foo:bar'
          }
        }
      }
    end

    it 'set up the policies' do
      is_expected.to contain_openstacklib__policy__base('context_is_admin').with({
        :key         => 'context_is_admin',
        :value       => 'foo:bar',
        :file_user   => 'root',
        :file_group  => 'trove',
        :file_format => 'yaml',
      })
      is_expected.to contain_oslo__policy('trove_config').with(
        :enforce_scope => false,
        :policy_file   => '/etc/trove/policy.yaml',
      )
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'trove::policy'
    end
  end
end
