# == Class: trove::guestagent
#
# Manages trove guest agent package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove guest agent service
#   Defaults to false
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*package_ensure*]
#   (optional) The state of the trove guest agent package
#   Defaults to 'present'
#
# [*debug*]
#   (optional) Rather to log the trove guest agent service at debug level.
#   Default: false
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $facts['os_service_default'], it will not log to any file.
#   Default: /var/log/trove/trove-guestagent.log
#
# [*log_dir*]
#    (optional) directory to which trove logs are sent.
#    If set to $facts['os_service_default'], it will not log to any directory.
#    Defaults to '/var/log/trove'
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to $facts['os_service_default']
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*swift_url*]
#   (optional) Swift URL. If this is unset in the class, Trove will
#   lookup the URL using the Keystone catalog.
#   Defaults to $facts['os_service_default'].
#
# [*swift_service_type*]
#   (optional) Service type to use when searching catalog
#   Defaults to $facts['os_service_default'].
#
# [*default_transport_url*]
#   (optional) A URL representing the messaging driver to use and its full
#   configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::trove::default_transport_url
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to the value set in the trove class.
#   The default can generally be left unless the
#   guests need to talk to the rabbit cluster via
#   a different ssl connection option.
#
# [*root_grant*]
#   (optional) Permissions to grant "root" user.
#   Defaults to $facts['os_service_default'].
#
# [*root_grant_option*]
#   (optional) Permissions to grant "root" user option.
#   Defaults to $facts['os_service_default'].
#
# [*container_registry*]
#   (optional) URL to the registry.
#   Defaults to $facts['os_service_default'].
#
# [*container_registry_username*]
#   (optional) The registry username.
#   Defaults to $facts['os_service_default'].
#
# [*container_registry_password*]
#   (optional) The plaintext registry password.
#   Defaults to $facts['os_service_default'].
#
# [*num_tries*]
#   (optional) Number of times to check if a volume exists.
#   Defaults to $facts['os_service_default'].
#
# [*volume_fstype*]
#   (optional) File system type used to format a volume.
#   Defaults to $facts['os_service_default'].
#
# [*format_options*]
#   (optional) Options to use when formatting a volume.
#   Defaults to $facts['os_service_default'].
#
# [*volume_format_timeout*]
#   (optional) Maximum time (in seconds) to wait for a volume format.
#   Defaults to $facts['os_service_default'].
#
# [*mount_options*]
#   (optional) Options to use when mounting a volume.
#   Defaults to $facts['os_service_default'].
#
#  DEPRECATED PARAMETERS
#
# [*default_password_length*]
#   (optional) Default password Length for root password.
#   Defaults to undef
#
# [*backup_aes_cbc_key*]
#   (optional) Default OpenSSL aes_cbc key
#   Defaults to undef
#
class trove::guestagent(
  Boolean $enabled             = false,
  Boolean $manage_service      = true,
  $package_ensure              = 'present',
  $debug                       = $facts['os_service_default'],
  $log_file                    = '/var/log/trove/trove-guestagent.log',
  $log_dir                     = '/var/log/trove',
  $use_syslog                  = $facts['os_service_default'],
  $log_facility                = $facts['os_service_default'],
  $swift_url                   = $facts['os_service_default'],
  $swift_service_type          = $facts['os_service_default'],
  $default_transport_url       = $::trove::default_transport_url,
  $rabbit_use_ssl              = $::trove::rabbit_use_ssl,
  $root_grant                  = $facts['os_service_default'],
  $root_grant_option           = $facts['os_service_default'],
  $container_registry          = $facts['os_service_default'],
  $container_registry_username = $facts['os_service_default'],
  $container_registry_password = $facts['os_service_default'],
  $num_tries                   = $facts['os_service_default'],
  $volume_fstype               = $facts['os_service_default'],
  $format_options              = $facts['os_service_default'],
  $volume_format_timeout       = $facts['os_service_default'],
  $mount_options               = $facts['os_service_default'],
  # DEPRECATED PARAMETERS
  $default_password_length     = undef,
  $backup_aes_cbc_key          = undef,
) inherits trove {

  include trove::deps
  include trove::params
  include trove::guestagent::service_credentials

  if $backup_aes_cbc_key != undef {
    warning('The parameter backup_aes_cbc_key is deprecated for removal')
  }

  # basic service config
  trove_guestagent_config {
    'DEFAULT/swift_url':               value => $swift_url;
    'DEFAULT/swift_service_type':      value => $swift_service_type;
    'DEFAULT/root_grant':              value => $root_grant;
    'DEFAULT/root_grant_option':       value => $root_grant_option;
    'DEFAULT/default_password_length': value => pick($default_password_length, $facts['os_service_default']);
    'DEFAULT/backup_aes_cbc_key':      value => pick($backup_aes_cbc_key, $facts['os_service_default']);
  }

  oslo::messaging::default { 'trove_guestagent_config':
    transport_url        => $default_transport_url,
    control_exchange     => $::trove::control_exchange,
    rpc_response_timeout => $::trove::rpc_response_timeout,
  }

  oslo::messaging::notifications { 'trove_guestagent_config':
    transport_url => $::trove::notification_transport_url,
    driver        => $::trove::notification_driver,
    topics        => $::trove::notification_topics
  }

  oslo::messaging::rabbit {'trove_guestagent_config':
    rabbit_ha_queues                => $::trove::rabbit_ha_queues,
    heartbeat_timeout_threshold     => $::trove::rabbit_heartbeat_timeout_threshold,
    heartbeat_rate                  => $::trove::rabbit_heartbeat_rate,
    heartbeat_in_pthread            => $::trove::rabbit_heartbeat_in_pthread,
    rabbit_qos_prefetch_count       => $::trove::rabbit_qos_prefetch_count,
    rabbit_use_ssl                  => $rabbit_use_ssl,
    kombu_reconnect_delay           => $::trove::kombu_reconnect_delay,
    kombu_failover_strategy         => $::trove::kombu_failover_strategy,
    amqp_durable_queues             => $::trove::amqp_durable_queues,
    kombu_ssl_ca_certs              => $::trove::kombu_ssl_ca_certs,
    kombu_ssl_certfile              => $::trove::kombu_ssl_certfile,
    kombu_ssl_keyfile               => $::trove::kombu_ssl_keyfile,
    kombu_ssl_version               => $::trove::kombu_ssl_version,
    rabbit_quorum_queue             => $::trove::rabbit_quorum_queue,
    rabbit_transient_quorum_queue   => $::trove::rabbit_transient_quorum_queue,
    rabbit_quorum_delivery_limit    => $::trove::rabbit_quorum_delivery_limit,
    rabbit_quorum_max_memory_length => $::trove::rabbit_quorum_max_memory_length,
    rabbit_quorum_max_memory_bytes  => $::trove::rabbit_quorum_max_memory_bytes,
    enable_cancel_on_failover       => $::trove::rabbit_enable_cancel_on_failover,
  }

  oslo::log { 'trove_guestagent_config':
    debug               => $debug,
    log_file            => $log_file,
    log_dir             => $log_dir,
    use_syslog          => $use_syslog,
    syslog_log_facility => $log_facility
  }

  trove::generic_service { 'guestagent':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::guestagent_package_name,
    service_name   => $::trove::params::guestagent_service_name,
    package_ensure => $package_ensure,
  }

  trove_guestagent_config {
    'guest_agent/container_registry':          value => $container_registry;
    'guest_agent/container_registry_username': value => $container_registry_username;
    'guest_agent/container_registry_password': value => $container_registry_password, secret => true;
  }

  trove_guestagent_config {
    'DEFAULT/num_tries':             value => $num_tries;
    'DEFAULT/volume_fstype':         value => $volume_fstype;
    'DEFAULT/format_options':        value => $format_options;
    'DEFAULT/volume_format_timeout': value => $volume_format_timeout;
    'DEFAULT/mount_options':         value => $mount_options;
  }
}
