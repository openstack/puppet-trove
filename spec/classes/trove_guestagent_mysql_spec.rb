require 'spec_helper'

describe 'trove::guestagent::mysql' do

  shared_examples 'trove::guestagent::mysql' do

    context 'with defaults' do
      it 'configures mysql options with defaultss' do
        is_expected.to contain_trove_guestagent_config('mysql/docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/backup_docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/icmp').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/root_on_create').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/usage_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/volume_support').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/ignore_users').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/ignore_dbs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/guest_log_exposed_logs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/guest_log_long_query_time').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('mysql/default_password_length').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters overridden' do
      let :params do
        {
          :docker_image              => 'mysql',
          :backup_docker_image       => 'openstacktrove/db-backup-mysql:1.1.0',
          :icmp                      => false,
          :root_on_create            => false,
          :usage_timeout             => 400,
          :volume_support            => true,
          :ignore_users              => ['os_admin', 'root'],
          :ignore_dbs                => ['mysql', 'information_schema', 'performance_schema', 'sys'],
          :guest_log_exposed_logs    => ['general', 'slow_query'],
          :guest_log_long_query_time => 1000,
          :default_password_length   => 36,
        }
      end

      it 'configures mysql options with given values' do
        is_expected.to contain_trove_guestagent_config('mysql/docker_image').with_value('mysql')
        is_expected.to contain_trove_guestagent_config('mysql/backup_docker_image').with_value('openstacktrove/db-backup-mysql:1.1.0')
        is_expected.to contain_trove_guestagent_config('mysql/icmp').with_value(false)
        is_expected.to contain_trove_guestagent_config('mysql/root_on_create').with_value(false)
        is_expected.to contain_trove_guestagent_config('mysql/usage_timeout').with_value(400)
        is_expected.to contain_trove_guestagent_config('mysql/volume_support').with_value(true)
        is_expected.to contain_trove_guestagent_config('mysql/ignore_users').with_value('os_admin,root')
        is_expected.to contain_trove_guestagent_config('mysql/ignore_dbs').with_value('mysql,information_schema,performance_schema,sys')
        is_expected.to contain_trove_guestagent_config('mysql/guest_log_exposed_logs').with_value('general,slow_query')
        is_expected.to contain_trove_guestagent_config('mysql/guest_log_long_query_time').with_value(1000)
        is_expected.to contain_trove_guestagent_config('mysql/default_password_length').with_value(36)
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
      it_configures 'trove::guestagent::mysql'
    end
  end

end
