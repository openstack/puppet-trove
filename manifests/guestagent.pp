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
# [*ensure_package*]
#   (optional) The state of the trove guest agent package
#   Defaults to 'present'
#
# [*verbose*]
#   (optional) Rather to log the trove guest agent service at verbose level.
#   Default: false
#
# [*debug*]
#   (optional) Rather to log the trove guest agent service at debug level.
#   Default: false
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Default: /var/log/trove/guestagent.log
#
# [*log_dir*]
#    (optional) directory to which trove logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to '/var/log/trove'
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to false.
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to 'http://localhost:5000/v2.0'.
#
# [*swift_url*]
#   (optional) Swift URL.
#   Defaults to 'http://localhost:8080/v1/AUTH_'.
#
# [*control_exchange*]
#   (optional) Control exchange.
#   Defaults to 'trove'.
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
  $ensure_package            = 'present',
  $verbose                   = false,
  $debug                     = false,
  $log_file                  = '/var/log/trove/guestagent.log',
  $log_dir                   = '/var/log/trove',
  $use_syslog                = false,
  $log_facility              = 'LOG_USER',
  $auth_url                  = 'http://localhost:5000/v2.0',
  $swift_url                 = 'http://localhost:8080/v1/AUTH_',
  $control_exchange          = 'trove',
  $rabbit_hosts              = $::trove::rabbit_hosts,
  $rabbit_host               = $::trove::rabbit_host,
  $rabbit_port               = $::trove::rabbit_port,
) inherits trove {

  include ::trove::deps
  include ::trove::params

  # basic service config
  trove_guestagent_config {
    'DEFAULT/verbose':                      value => $verbose;
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/trove_auth_url':               value => $auth_url;
    'DEFAULT/swift_url':                    value => $swift_url;
  }

  oslo::messaging::default { 'trove_config':
      control_exchange => $control_exchange
  }

  # region name
  if $::trove::os_region_name {
    trove_guestagent_config { 'DEFAULT/os_region_name': value => $::trove::os_region_name }
  }
  else {
    trove_guestagent_config { 'DEFAULT/os_region_name': ensure => absent }
  }

  oslo::messaging::notifications { 'trove_guestagent_config':
    driver => $::trove::notification_driver,
    topics => $::trove::notification_topics
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_kombu' or $::trove::rpc_backend == 'rabbit' {
    oslo::messaging::rabbit {'trove_guestagent_config':
      rabbit_hosts          => $rabbit_hosts,
      rabbit_host           => $rabbit_host,
      rabbit_port           => $rabbit_port,
      rabbit_ha_queues      => $::trove::rabbit_ha_queues,
      rabbit_userid         => $::trove::rabbit_userid,
      rabbit_password       => $::trove::rabbit_password,
      rabbit_virtual_host   => $::trove::rabbit_virtual_host,
      rabbit_use_ssl        => $::trove::rabbit_use_ssl,
      kombu_reconnect_delay => $::trove::kombu_reconnect_delay,
      amqp_durable_queues   => $::trove::amqp_durable_queues,
      kombu_ssl_ca_certs    => $::trove::kombu_ssl_ca_certs,
      kombu_ssl_certfile    => $::trove::kombu_ssl_certfile,
      kombu_ssl_keyfile     => $::trove::kombu_ssl_keyfile,
      kombu_ssl_version     => $::trove::kombu_ssl_version
    }
  } else {
    trove_guestagent_config {
      'DEFAULT/rpc_backend' : value => $::trove::rpc_backend
    }
  }

  # Logging
  if $log_file {
    trove_guestagent_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    trove_guestagent_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    trove_guestagent_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    trove_guestagent_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    trove_guestagent_config {
      'DEFAULT/use_syslog'          : value => true;
      'DEFAULT/syslog_log_facility' : value => $log_facility;
    }
  } else {
    trove_guestagent_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  trove::generic_service { 'guestagent':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::guestagent_package_name,
    service_name   => $::trove::params::guestagent_service_name,
    ensure_package => $ensure_package,
  }

}
