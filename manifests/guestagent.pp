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
  $control_exchange          = 'trove'
) inherits trove {

  include ::trove::params

  Trove_guestagent_config<||> ~> Exec['post-trove_config']
  Trove_guestagent_config<||> ~> Service['trove-guestagent']
  # Trove db sync is broken in Ubuntu packaging
  # This is a temporary fix until it's fixed in packaging.
  # https://bugs.launchpad.net/ubuntu/+source/openstack-trove/+bug/1451134
  file { '/etc/trove/trove-guestagent.conf':
    require => File['/etc/trove'],
  }
  File['/etc/trove/trove-guestagent.conf'] -> Trove_guestagent_config<||>
  Trove_guestagent_config<||> -> Package[$::trove::params::guestagent_package_name]

  # basic service config
  trove_guestagent_config {
    'DEFAULT/verbose':                      value => $verbose;
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/trove_auth_url':               value => $auth_url;
    'DEFAULT/swift_url':                    value => $swift_url;
    'DEFAULT/nova_proxy_admin_user':        value => $::trove::nova_proxy_admin_user;
    'DEFAULT/nova_proxy_admin_tenant_name': value => $::trove::nova_proxy_admin_tenant_name;
    'DEFAULT/nova_proxy_admin_pass':        value => $::trove::nova_proxy_admin_pass;
    'DEFAULT/control_exchange':             value => $control_exchange;
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_kombu' {
      if ! $::trove::rabbit_password {
      fail('When rpc_backend is rabbitmq, you must set rabbit password')
    }
    if $::trove::rabbit_hosts {
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_hosts':     value  => join($::trove::rabbit_hosts, ',') }
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value  => true }
    } else  {
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_host':      value => $::trove::rabbit_host }
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_port':      value => $::trove::rabbit_port }
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => "${::trove::rabbit_host}:${::trove::rabbit_port}" }
      trove_guestagent_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
    }

    trove_guestagent_config {
      'oslo_messaging_rabbit/rabbit_userid':         value => $::trove::rabbit_userid;
      'oslo_messaging_rabbit/rabbit_password':       value => $::trove::rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_virtual_host':   value => $::trove::rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':        value => $::trove::rabbit_use_ssl;
      'oslo_messaging_rabbit/kombu_reconnect_delay': value => $::trove::kombu_reconnect_delay;
    }

    if $::trove::rabbit_use_ssl {

      if $::trove::kombu_ssl_ca_certs {
        trove_guestagent_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $::trove::kombu_ssl_ca_certs; }
      } else {
        trove_guestagent_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $::trove::kombu_ssl_certfile or $::trove::kombu_ssl_keyfile {
        trove_guestagent_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $::trove::kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $::trove::kombu_ssl_keyfile;
        }
      } else {
        trove_guestagent_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $::trove::kombu_ssl_version {
        trove_guestagent_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $::trove::kombu_ssl_version; }
      } else {
        trove_guestagent_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      trove_guestagent_config {
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
      }
    }
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_qpid' {
    trove_guestagent_config {
      'DEFAULT/qpid_hostname':               value => $::trove::qpid_hostname;
      'DEFAULT/qpid_port':                   value => $::trove::qpid_port;
      'DEFAULT/qpid_username':               value => $::trove::qpid_username;
      'DEFAULT/qpid_password':               value => $::trove::qpid_password, secret => true;
      'DEFAULT/qpid_heartbeat':              value => $::trove::qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $::trove::qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $::trove::qpid_tcp_nodelay;
    }
    if is_array($::trove::qpid_sasl_mechanisms) {
      trove_guestagent_config {
        'DEFAULT/qpid_sasl_mechanisms': value => join($::trove::qpid_sasl_mechanisms, ' ');
      }
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
