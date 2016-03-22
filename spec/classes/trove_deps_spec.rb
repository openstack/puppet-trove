require 'spec_helper'

describe 'trove::deps' do

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
