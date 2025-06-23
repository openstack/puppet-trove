require 'spec_helper'

describe 'trove::guestagent::postgresql' do

  shared_examples 'trove::guestagent::postgresql' do

    context 'with defaults' do
      it 'configures postgresql options with defaultss' do
        is_expected.to contain_trove_guestagent_config('postgresql/docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/backup_docker_image').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/icmp').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/root_on_create').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/usage_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/volume_support').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/ignore_users').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/ignore_dbs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/guest_log_exposed_logs').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_trove_guestagent_config('postgresql/default_password_length').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters overridden' do
      let :params do
        {
          :docker_image              => 'postgresql',
          :backup_docker_image       => 'openstacktrove/db-backup-postgresql:1.1.0',
          :icmp                      => false,
          :root_on_create            => false,
          :usage_timeout             => 400,
          :volume_support            => true,
          :ignore_users              => ['os_admin', 'postgres'],
          :ignore_dbs                => ['os_admin', 'postgres'],
          :guest_log_exposed_logs    => ['general'],
          :default_password_length   => 36,
        }
      end

      it 'configures postgresql options with given values' do
        is_expected.to contain_trove_guestagent_config('postgresql/docker_image').with_value('postgresql')
        is_expected.to contain_trove_guestagent_config('postgresql/backup_docker_image').with_value('openstacktrove/db-backup-postgresql:1.1.0')
        is_expected.to contain_trove_guestagent_config('postgresql/icmp').with_value(false)
        is_expected.to contain_trove_guestagent_config('postgresql/root_on_create').with_value(false)
        is_expected.to contain_trove_guestagent_config('postgresql/usage_timeout').with_value(400)
        is_expected.to contain_trove_guestagent_config('postgresql/volume_support').with_value(true)
        is_expected.to contain_trove_guestagent_config('postgresql/ignore_users').with_value('os_admin,postgres')
        is_expected.to contain_trove_guestagent_config('postgresql/ignore_dbs').with_value('os_admin,postgres')
        is_expected.to contain_trove_guestagent_config('postgresql/guest_log_exposed_logs').with_value('general')
        is_expected.to contain_trove_guestagent_config('postgresql/default_password_length').with_value(36)
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
      it_configures 'trove::guestagent::postgresql'
    end
  end

end
