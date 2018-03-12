require 'spec_helper'

describe 'trove::db::sync' do

  shared_examples_for 'trove-dbsync' do

    it { is_expected.to contain_class('trove::deps') }

    it 'runs trove-db-sync' do
      is_expected.to contain_exec('trove-manage db_sync').with(
        :command     => 'trove-manage db_sync',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :user        => 'trove',
        :try_sleep   => 5,
        :tries       => 10,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[trove::install::end]',
                         'Anchor[trove::config::end]',
                         'Anchor[trove::dbsync::begin]'],
        :notify      => 'Anchor[trove::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'trove-dbsync'
    end
  end

end
