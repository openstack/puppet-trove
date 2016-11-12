require 'spec_helper'

describe 'trove::deps' do

  shared_examples_for 'trove::deps' do
    context 'defaults' do
      it 'set up the anchors' do
        is_expected.to contain_anchor('trove::install::begin')
        is_expected.to contain_anchor('trove::install::end')
        is_expected.to contain_anchor('trove::config::begin')
        is_expected.to contain_anchor('trove::config::end')
        is_expected.to contain_anchor('trove::db::begin')
        is_expected.to contain_anchor('trove::db::end')
        is_expected.to contain_anchor('trove::dbsync::begin')
        is_expected.to contain_anchor('trove::dbsync::end')
        is_expected.to contain_anchor('trove::service::begin')
        is_expected.to contain_anchor('trove::service::end')
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

      it_configures 'trove::deps'
    end
  end

end
