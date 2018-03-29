# == Class: trove::conductor
#
# Manages trove conductor package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove-conductor service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*package_ensure*]
#   (optional) The state of the trove conductor package
#   Defaults to 'present'
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: false
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $::os_service_default, it will not log to any file.
#   Default: /var/log/trove/trove-conductor.log
#
# [*log_dir*]
#    (optional) directory to which trove logs are sent.
#    If set to $::os_service_default, it will not log to any directory.
#    Defaults to '/var/log/trove'
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to $::os_service_default
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to 'http://localhost:5000/v3'.
#
# [*conductor_manager*]
#   (optional) Trove conductor manager.
#   Defaults to 'trove.conductor.manager.Manager'.
#
# [*workers*]
#   (optional) Number of trove conductor worker processes to start
#   Default: $::os_workers
#
# [*enable_profiler*]
#   (optional) If False fully disable profiling feature.
#   Default: $::os_service_default
#
# [*trace_sqlalchemy*]
#   (optional) If False doesn't trace SQL requests.
#   Default: $::os_service_default
#
class trove::conductor(
  $enabled           = true,
  $manage_service    = true,
  $package_ensure    = 'present',
  $debug             = $::os_service_default,
  $log_file          = '/var/log/trove/trove-conductor.log',
  $log_dir           = '/var/log/trove',
  $use_syslog        = $::os_service_default,
  $log_facility      = $::os_service_default,
  $auth_url          = 'http://localhost:5000/v3',
  $conductor_manager = 'trove.conductor.manager.Manager',
  $workers           = $::os_workers,
  $enable_profiler   = $::os_service_default,
  $trace_sqlalchemy  = $::os_service_default,
) inherits trove {

  include ::trove::deps
  include ::trove::params

  if $::trove::database_connection {
    if($::trove::database_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require '::mysql::bindings'
      require '::mysql::bindings::python'
    } elsif($::trove::database_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($::trove::database_connection =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${::trove::database_connection}")
    }
    trove_conductor_config {
      'database/connection':   value => $::trove::database_connection;
      'database/idle_timeout': value => $::trove::database_idle_timeout;
    }
  }

  # basic service config
  $trove_auth_url = "${regsubst($auth_url, '(\/v3$|\/v2.0$|\/$)', '')}/v3"
  trove_conductor_config {
    'DEFAULT/trove_auth_url':               value => $trove_auth_url;
    'DEFAULT/nova_proxy_admin_user':        value => $::trove::nova_proxy_admin_user;
    'DEFAULT/nova_proxy_admin_tenant_name': value => $::trove::nova_proxy_admin_tenant_name;
    'DEFAULT/nova_proxy_admin_pass':        value => $::trove::nova_proxy_admin_pass;
    'DEFAULT/trove_conductor_workers':      value => $workers;
  }
  # profiler config
  trove_conductor_config {
    'profiler/enabled':          value => $enable_profiler;
    'profiler/trace_sqlalchemy': value => $trace_sqlalchemy;
  }

  if $::trove::single_tenant_mode {
    trove_conductor_config {
      'DEFAULT/remote_nova_client':    value => 'trove.common.single_tenant_remote.nova_client_trove_admin';
      'DEFAULT/remote_cinder_client':  value => 'trove.common.single_tenant_remote.cinder_client_trove_admin';
      'DEFAULT/remote_neutron_client': value => 'trove.common.single_tenant_remote.neutron_client_trove_admin';
    }
  }
  else {
    trove_conductor_config {
      'DEFAULT/remote_nova_client':    ensure => absent;
      'DEFAULT/remote_cinder_client':  ensure => absent;
      'DEFAULT/remote_neutron_client': ensure => absent;
    }
  }

  oslo::messaging::default { 'trove_conductor_config':
    transport_url        => $::trove::default_transport_url,
    control_exchange     => $::trove::control_exchange,
    rpc_response_timeout => $::trove::rpc_response_timeout,
  }

  oslo::messaging::notifications { 'trove_conductor_config':
    transport_url => $::trove::notification_transport_url,
    driver        => $::trove::notification_driver,
    topics        => $::trove::notification_topics
  }

  oslo::messaging::rabbit {'trove_conductor_config':
    rabbit_hosts            => $::trove::rabbit_hosts,
    rabbit_host             => $::trove::rabbit_host,
    rabbit_port             => $::trove::rabbit_port,
    rabbit_ha_queues        => $::trove::rabbit_ha_queues,
    rabbit_userid           => $::trove::rabbit_userid,
    rabbit_password         => $::trove::rabbit_password,
    rabbit_virtual_host     => $::trove::rabbit_virtual_host,
    rabbit_use_ssl          => $::trove::rabbit_use_ssl,
    kombu_reconnect_delay   => $::trove::kombu_reconnect_delay,
    kombu_failover_strategy => $::trove::kombu_failover_strategy,
    amqp_durable_queues     => $::trove::amqp_durable_queues,
    kombu_ssl_ca_certs      => $::trove::kombu_ssl_ca_certs,
    kombu_ssl_certfile      => $::trove::kombu_ssl_certfile,
    kombu_ssl_keyfile       => $::trove::kombu_ssl_keyfile,
    kombu_ssl_version       => $::trove::kombu_ssl_version
  }

  oslo::messaging::amqp { 'trove_conductor_config':
    server_request_prefix  => $::trove::amqp_server_request_prefix,
    broadcast_prefix       => $::trove::amqp_broadcast_prefix,
    group_request_prefix   => $::trove::amqp_group_request_prefix,
    container_name         => $::trove::amqp_container_name,
    idle_timeout           => $::trove::amqp_idle_timeout,
    trace                  => $::trove::amqp_trace,
    ssl_ca_file            => $::trove::amqp_ssl_ca_file,
    ssl_cert_file          => $::trove::amqp_ssl_cert_file,
    ssl_key_file           => $::trove::amqp_ssl_key_file,
    ssl_key_password       => $::trove::amqp_ssl_key_password,
    allow_insecure_clients => $::trove::amqp_allow_insecure_clients,
    sasl_mechanisms        => $::trove::amqp_sasl_mechanisms,
    sasl_config_dir        => $::trove::amqp_sasl_config_dir,
    sasl_config_name       => $::trove::amqp_sasl_config_name,
    username               => $::trove::amqp_username,
    password               => $::trove::amqp_password,
  }

  oslo::log { 'trove_conductor_config':
    debug               => $debug,
    log_file            => $log_file,
    log_dir             => $log_dir,
    use_syslog          => $use_syslog,
    syslog_log_facility => $log_facility
  }

  trove::generic_service { 'conductor':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::conductor_package_name,
    service_name   => $::trove::params::conductor_service_name,
    package_ensure => $package_ensure,
  }

}
