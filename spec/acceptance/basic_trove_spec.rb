require 'spec_helper_acceptance'

describe 'basic trove' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release         => 'kilo',
            package_require => true,
          }
          $package_provider = 'apt'
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            release => 'kilo',
          }
          package { 'openstack-selinux': ensure => 'latest' }
          $package_provider = 'yum'
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }

      class { '::mysql::server': }

      class { '::rabbitmq':
        delete_guest_user => true,
        package_provider  => $package_provider,
      }

      rabbitmq_vhost { '/':
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

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

      # Keystone resources, needed by Trove to run
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      class { '::keystone::roles::admin':
        email    => 'test@example.tld',
        password => 'a_big_secret',
      }
      class { '::keystone::endpoint':
        public_url => "https://${::fqdn}:5000/",
        admin_url  => "https://${::fqdn}:35357/",
      }

      # Trove resources
      class { '::trove':
        database_connection   => 'mysql://trove:a_big_secret@127.0.0.1/trove?charset=utf8',
        rabbit_userid         => 'trove',
        rabbit_password       => 'an_even_bigger_secret',
        rabbit_host           => '127.0.0.1',
        nova_proxy_admin_pass => 'a_big_secret',
      }
      class { '::trove::db::mysql':
        password => 'a_big_secret',
      }
      class { '::trove::keystone::auth':
        password => 'a_big_secret',
      }
      class { '::trove::api':
        keystone_password => 'a_big_secret',
        auth_url          => 'http://127.0.0.1:35357/',
        debug             => true,
        verbose           => true,
      }
      class { '::trove::client': }
      class { '::trove::conductor':
        debug   => true,
        verbose => true,
      }
      class { '::trove::taskmanager':
        debug   => true,
        verbose => true,
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
