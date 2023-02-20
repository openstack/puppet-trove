require 'spec_helper'

describe 'trove::guestagent::mariadb' do

  shared_examples 'trove::guestagent::mariadb' do

    context 'with defaults' do
      it 'configures mariadb options with defaultss' do
        is_expected.to contain_trove_guestagent_config('mariadb/docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/backup_docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/icmp').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/root_on_create').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/usage_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/volume_support').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/ignore_users').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/ignore_dbs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/guest_log_exposed_logs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/guest_log_long_query_time').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mariadb/default_password_length').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters overridden' do
      let :params do
        {
          :docker_image              => 'mariadb',
          :backup_docker_image       => 'openstacktrove/db-backup-mariadb:1.1.0',
          :icmp                      => false,
          :root_on_create            => false,
          :usage_timeout             => 400,
          :volume_support            => true,
          :ignore_users              => ['os_admin', 'root'],
          :ignore_dbs                => ['mariadb', 'information_schema', 'performance_schema', 'sys'],
          :guest_log_exposed_logs    => ['general', 'slow_query'],
          :guest_log_long_query_time => 1000,
          :cluster_support           => true,
          :min_cluster_member_count  => 3,
          :default_password_length   => 36,
        }
      end

      it 'configures mariadb options with given values' do
        is_expected.to contain_trove_guestagent_config('mariadb/docker_image').with_value('mariadb')
        is_expected.to contain_trove_guestagent_config('mariadb/backup_docker_image').with_value('openstacktrove/db-backup-mariadb:1.1.0')
        is_expected.to contain_trove_guestagent_config('mariadb/icmp').with_value(false)
        is_expected.to contain_trove_guestagent_config('mariadb/root_on_create').with_value(false)
        is_expected.to contain_trove_guestagent_config('mariadb/usage_timeout').with_value(400)
        is_expected.to contain_trove_guestagent_config('mariadb/volume_support').with_value(true)
        is_expected.to contain_trove_guestagent_config('mariadb/ignore_users').with_value('os_admin,root')
        is_expected.to contain_trove_guestagent_config('mariadb/ignore_dbs').with_value('mariadb,information_schema,performance_schema,sys')
        is_expected.to contain_trove_guestagent_config('mariadb/guest_log_exposed_logs').with_value('general,slow_query')
        is_expected.to contain_trove_guestagent_config('mariadb/guest_log_long_query_time').with_value(1000)
        is_expected.to contain_trove_guestagent_config('mariadb/cluster_support').with_value(true)
        is_expected.to contain_trove_guestagent_config('mariadb/min_cluster_member_count').with_value(3)
        is_expected.to contain_trove_guestagent_config('mariadb/default_password_length').with_value(36)
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts())
    end

    context "on #{os}" do
      it_configures 'trove::guestagent::mariadb'
    end
  end

end
