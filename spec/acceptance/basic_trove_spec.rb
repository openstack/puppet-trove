require 'spec_helper_acceptance'

describe 'basic trove' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      rabbitmq_user { 'trove':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'trove@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      # Trove resources
      class { '::trove':
        database_connection   => 'mysql+pymysql://trove:a_big_secret@127.0.0.1/trove?charset=utf8',
        default_transport_url => 'rabbit://trove:an_even_bigger_secret@127.0.0.1:5672/',
        nova_proxy_admin_pass => 'a_big_secret',
      }
      class { '::trove::db::mysql':
        password => 'a_big_secret',
      }
      class { '::trove::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::trove::keystone::authtoken':
        password => 'a_big_secret',
      }
      class { '::trove::api':
        debug             => true,
      }
      class { '::trove::client': }
      class { '::trove::conductor':
        debug   => true,
      }
      if ($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemmajrelease, '16') >= 0) {
        warning('trove::taskmanager is disabled now, not working correctly on Xenial.')
      } else {
        class { '::trove::taskmanager':
          debug   => true,
        }
      }
      class { '::trove::quota': }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8779) do
      it { is_expected.to be_listening.with('tcp') }
    end

  end
end
