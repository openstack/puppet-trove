# == Class: trove::guestagent
#
# Manages trove guest agent package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove guest agent service
#   Defaults to true
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
#   If set to $::os_service_default, it will not log to any file.
#   Default: /var/log/trove/trove-guestagent.log
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
# [*swift_url*]
#   (optional) Swift URL. If this is unset in the class, Trove will
#   lookup the URL using the Keystone catalog.
#   Defaults to $::os_service_default.
#
# [*swift_service_type*]
#   (optional) Service type to use when searching catalog
#   Defaults to $::os_service_default.
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
# [*backup_aes_cbc_key*]
#   (optional) Default OpenSSL aes_cbc key
#   Defaults to $::os_service_default.
#
#  DEPRECATED PARAMETERS
#
# [*root_grant*]
#   (optional) Permissions to grant "root" user.
#   Defaults to $::os_service_default.
#
# [*root_grant_option*]
#   (optional) Permissions to grant "root" user option.
#   Defaults to $::os_service_default.
#
# [*default_password_length*]
#   (optional) Default password Length for root password.
#   Defaults to $::os_service_default.
#
# [*control_exchange*]
#   (Optional) Moved to init.pp. The default exchange to scope topics.
#   Defaults to undef.
#
# [*rabbit_hosts*]
#   (optional) List of clustered rabbit servers.
#   Defaults to the value set in the trove class.
#   The default can generally be left unless the
#   guests need to talk to the rabbit cluster via
#   different IPs.
#
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#   Defaults to the value set in the trove class.
#   The default can generally be left unless the
#   guests need to talk to the rabbit cluster via
#   a different IP.
#
# [*rabbit_port*]
#   (optional) Port for rabbitmq instance.
#   Defaults to the value set in the trove class.
#   The default can generally be left unless the
#   guests need to talk to the rabbit cluster via
#   a different port.
#
class trove::guestagent(
  $enabled                   = true,
  $manage_service            = true,
  $package_ensure            = 'present',
  $debug                     = $::os_service_default,
  $log_file                  = '/var/log/trove/trove-guestagent.log',
  $log_dir                   = '/var/log/trove',
  $use_syslog                = $::os_service_default,
  $log_facility              = $::os_service_default,
  $auth_url                  = 'http://localhost:5000/v3',
  $swift_url                 = $::os_service_default,
  $swift_service_type        = $::os_service_default,
  $default_transport_url     = $::trove::default_transport_url,
  $rabbit_use_ssl            = $::trove::rabbit_use_ssl,
  $root_grant                = $::os_service_default,
  $root_grant_option         = $::os_service_default,
  $default_password_length   = $::os_service_default,
  $backup_aes_cbc_key        = $::os_service_default,
  #Deprecated
  $control_exchange          = undef,
  $rabbit_hosts              = $::trove::rabbit_hosts,
  $rabbit_host               = $::trove::rabbit_host,
  $rabbit_port               = $::trove::rabbit_port,
) inherits trove {

  include ::trove::deps
  include ::trove::params

  if !is_service_default($rabbit_host) or
    !is_service_default($rabbit_hosts) or
    !is_service_default($rabbit_port) {
    warning("trove::guestagent::rabbit_host, trove::guestagent::rabbit_hosts, \
and trove::guestagent::rabbit_port are deprecated. Please use \
trove::guestagent::default_transport_url instead.")
  }

  if $control_exchange {
    warning("control_exchange parameter is deprecated. Please use \
trove::control_exchange instead.")
  }

  $trove_auth_url = "${regsubst($auth_url, '(\/v3$|\/v2.0$|\/$)', '')}/v3"

  # basic service config
  trove_guestagent_config {
    'DEFAULT/trove_auth_url':          value => $trove_auth_url;
    'DEFAULT/swift_url':               value => $swift_url;
    'DEFAULT/swift_service_type':      value => $swift_service_type;
    'DEFAULT/root_grant':              value => $root_grant;
    'DEFAULT/root_grant_option':       value => $root_grant_option;
    'DEFAULT/default_password_length': value => $default_password_length;
    'DEFAULT/backup_aes_cbc_key':      value => $backup_aes_cbc_key;
  }

  oslo::messaging::default { 'trove_guestagent_config':
    transport_url        => $default_transport_url,
    control_exchange     => $::trove::control_exchange,
    rpc_response_timeout => $::trove::rpc_response_timeout,
  }

  # region name
  if $::trove::os_region_name {
    trove_guestagent_config { 'DEFAULT/os_region_name': value => $::trove::os_region_name }
  }
  else {
    trove_guestagent_config { 'DEFAULT/os_region_name': ensure => absent }
  }

  oslo::messaging::notifications { 'trove_guestagent_config':
    transport_url => $::trove::notification_transport_url,
    driver        => $::trove::notification_driver,
    topics        => $::trove::notification_topics
  }

  oslo::messaging::rabbit {'trove_guestagent_config':
    rabbit_hosts            => $rabbit_hosts,
    rabbit_host             => $rabbit_host,
    rabbit_port             => $rabbit_port,
    rabbit_use_ssl          => $rabbit_use_ssl,
    rabbit_ha_queues        => $::trove::rabbit_ha_queues,
    rabbit_userid           => $::trove::rabbit_userid,
    rabbit_password         => $::trove::rabbit_password,
    rabbit_virtual_host     => $::trove::rabbit_virtual_host,
    kombu_reconnect_delay   => $::trove::kombu_reconnect_delay,
    kombu_failover_strategy => $::trove::kombu_failover_strategy,
    amqp_durable_queues     => $::trove::amqp_durable_queues,
    kombu_ssl_ca_certs      => $::trove::kombu_ssl_ca_certs,
    kombu_ssl_certfile      => $::trove::kombu_ssl_certfile,
    kombu_ssl_keyfile       => $::trove::kombu_ssl_keyfile,
    kombu_ssl_version       => $::trove::kombu_ssl_version
  }

  oslo::messaging::amqp { 'trove_guestagent_config':
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

}
