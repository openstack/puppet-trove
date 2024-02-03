require 'spec_helper'

describe 'trove::cache' do

  let :params do
    {}
  end

  shared_examples_for 'trove::cache' do

    context 'with default parameters' do
      it 'configures cache' do
        is_expected.to contain_oslo__cache('trove_config').with(
          :config_prefix                        => '<SERVICE DEFAULT>',
          :expiration_time                      => '<SERVICE DEFAULT>',
          :backend                              => '<SERVICE DEFAULT>',
          :backend_argument                     => '<SERVICE DEFAULT>',
          :proxies                              => '<SERVICE DEFAULT>',
          :enabled                              => '<SERVICE DEFAULT>',
          :debug_cache_backend                  => '<SERVICE DEFAULT>',
          :memcache_servers                     => '<SERVICE DEFAULT>',
          :memcache_dead_retry                  => '<SERVICE DEFAULT>',
          :memcache_socket_timeout              => '<SERVICE DEFAULT>',
          :enable_socket_keepalive              => '<SERVICE DEFAULT>',
          :socket_keepalive_idle                => '<SERVICE DEFAULT>',
          :socket_keepalive_interval            => '<SERVICE DEFAULT>',
          :socket_keepalive_count               => '<SERVICE DEFAULT>',
          :memcache_pool_maxsize                => '<SERVICE DEFAULT>',
          :memcache_pool_unused_timeout         => '<SERVICE DEFAULT>',
          :memcache_pool_connection_get_timeout => '<SERVICE DEFAULT>',
          :memcache_pool_flush_on_reconnect     => '<SERVICE DEFAULT>',
          :tls_enabled                          => '<SERVICE DEFAULT>',
          :tls_cafile                           => '<SERVICE DEFAULT>',
          :tls_certfile                         => '<SERVICE DEFAULT>',
          :tls_keyfile                          => '<SERVICE DEFAULT>',
          :tls_allowed_ciphers                  => '<SERVICE DEFAULT>',
          :enable_retry_client                  => '<SERVICE DEFAULT>',
          :retry_attempts                       => '<SERVICE DEFAULT>',
          :retry_delay                          => '<SERVICE DEFAULT>',
          :hashclient_retry_attempts            => '<SERVICE DEFAULT>',
          :hashclient_retry_delay               => '<SERVICE DEFAULT>',
          :dead_timeout                         => '<SERVICE DEFAULT>',
          :manage_backend_package               => true,
        )
      end
    end

    context 'with overridden parameters' do
      let :params do
        {
          :config_prefix                        => 'prefix',
          :expiration_time                      => 3600,
          :backend                              => 'oslo_cache.memcache_pool',
          :proxies                              => ['proxy01:8888', 'proxy02:8888'],
          :enabled                              => true,
          :debug_cache_backend                  => false,
          :memcache_servers                     => ['memcached01:11211', 'memcached02:11211'],
          :memcache_dead_retry                  => '60',
          :memcache_socket_timeout              => '300.0',
          :enable_socket_keepalive              => false,
          :socket_keepalive_idle                => 1,
          :socket_keepalive_interval            => 1,
          :socket_keepalive_count               => 1,
          :memcache_pool_maxsize                => '10',
          :memcache_pool_unused_timeout         => '120',
          :memcache_pool_connection_get_timeout => '360',
          :memcache_pool_flush_on_reconnect     => false,
          :tls_enabled                          => false,
          :enable_retry_client                  => false,
          :retry_attempts                       => 2,
          :retry_delay                          => 0,
          :hashclient_retry_attempts            => 2,
          :hashclient_retry_delay               => 1,
          :dead_timeout                         => 60,
          :manage_backend_package               => false,
        }
      end

      it 'configures cache' do
        is_expected.to contain_oslo__cache('trove_config').with(
          :config_prefix                        => 'prefix',
          :expiration_time                      => 3600,
          :backend                              => 'oslo_cache.memcache_pool',
          :backend_argument                     => '<SERVICE DEFAULT>',
          :proxies                              => ['proxy01:8888', 'proxy02:8888'],
          :enabled                              => true,
          :debug_cache_backend                  => false,
          :memcache_servers                     => ['memcached01:11211', 'memcached02:11211'],
          :memcache_dead_retry                  => '60',
          :memcache_socket_timeout              => '300.0',
          :enable_socket_keepalive              => false,
          :socket_keepalive_idle                => 1,
          :socket_keepalive_interval            => 1,
          :socket_keepalive_count               => 1,
          :memcache_pool_maxsize                => '10',
          :memcache_pool_unused_timeout         => '120',
          :memcache_pool_connection_get_timeout => '360',
          :memcache_pool_flush_on_reconnect     => false,
          :tls_enabled                          => false,
          :tls_cafile                           => '<SERVICE DEFAULT>',
          :tls_certfile                         => '<SERVICE DEFAULT>',
          :tls_keyfile                          => '<SERVICE DEFAULT>',
          :tls_allowed_ciphers                  => '<SERVICE DEFAULT>',
          :enable_retry_client                  => false,
          :retry_attempts                       => 2,
          :retry_delay                          => 0,
          :hashclient_retry_attempts            => 2,
          :hashclient_retry_delay               => 1,
          :dead_timeout                         => 60,
          :manage_backend_package               => false,
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'trove::cache'
    end
  end

end
