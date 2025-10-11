#
# Unit tests for trove::keystone::auth
#

require 'spec_helper'

describe 'trove::keystone::auth' do
  shared_examples_for 'trove::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'trove_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('trove').with(
        :configure_user      => true,
        :configure_user_role => true,
        :configure_endpoint  => true,
        :configure_service   => true,
        :service_name        => 'trove',
        :service_type        => 'database',
        :service_description => 'Trove Database Service',
        :region              => 'RegionOne',
        :auth_name           => 'trove',
        :password            => 'trove_password',
        :email               => 'trove@localhost',
        :tenant              => 'services',
        :roles               => ['admin', 'service'],
        :system_scope        => 'all',
        :system_roles        => [],
        :public_url          => 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
        :internal_url        => 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
        :admin_url           => 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        { :password            => 'trove_password',
          :auth_name           => 'alt_trove',
          :email               => 'alt_trove@alt_localhost',
          :tenant              => 'alt_service',
          :roles               => ['admin'],
          :system_scope        => 'alt_all',
          :system_roles        => ['admin', 'member', 'reader'],
          :configure_endpoint  => false,
          :configure_user      => false,
          :configure_user_role => false,
          :configure_service   => false,
          :service_description => 'Alternative Trove Database Service',
          :service_name        => 'alt_service',
          :service_type        => 'alt_database',
          :region              => 'RegionTwo',
          :public_url          => 'https://10.10.10.10:80',
          :internal_url        => 'http://10.10.10.11:81',
          :admin_url           => 'http://10.10.10.12:81' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('trove').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :configure_service   => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_database',
        :service_description => 'Alternative Trove Database Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_trove',
        :password            => 'trove_password',
        :email               => 'alt_trove@alt_localhost',
        :tenant              => 'alt_service',
        :roles               => ['admin'],
        :system_scope        => 'alt_all',
        :system_roles        => ['admin', 'member', 'reader'],
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'trove::keystone::auth'
    end
  end
end
