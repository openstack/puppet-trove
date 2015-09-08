#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class trove::api
#
# Configure API service in trove
#
# == Parameters
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ensure_package*]
#   (optional) Whether the trove api package will be installed
#   Defaults to 'present'
#
# [*keystone_password*]
#   (required) Password used to authentication.
#
# [*verbose*]
#   (optional) Rather to log the trove api service at verbose level.
#   Default: false
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: false
#
# [*bind_host*]
#   (optional) The address of the host to bind to.
#   Default: 0.0.0.0
#
# [*bind_port*]
#   (optional) The port the server should bind to.
#   Default: 8779
#
# [*backlog*]
#   (optional) Backlog requests when creating socket
#   Default: 4096
#
# [*workers*]
#   (optional) Number of trove API worker processes to start
#   Default: $::processorcount
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Default: /var/log/trove/trove-api.log
#
# [*log_dir*]
#   (optional) directory to which trove logs are sent.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/trove'
#
# [*auth_host*]
#   (optional) Host running auth service.
#   Defaults to '127.0.0.1'.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to 'http://localhost:5000/v2.0'.
#
# [*auth_port*]
#   (optional) Port to use for auth service on auth_host.
#   Defaults to '35357'.
#
# [*auth_protocol*]
#   (optional) Protocol to use for auth.
#   Defaults to 'http'.
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate to.
#   Defaults to services.
#
# [*keystone_user*]
#   (optional) User to authenticate as with keystone.
#   Defaults to 'trove'.
#
# [*enabled*]
#   (optional) Whether to enable services.
#   Defaults to true.
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to false.
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the api config.
#   Defaults to false.
#
# [*cert_file*]
#   (optinal) Certificate file to use when starting API server securely
#   Defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting API server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set
#
# [*http_get_rate*]
#   (optional) Default rate limit of GET request.
#   Defaults to 200.
#
# [*http_post_rate*]
#   (optional) Default rate limit of POST request.
#   Defaults to 200.
#
# [*http_put_rate*]
#   (optional) Default rate limit of PUT request.
#   Defaults to 200.
#
# [*http_delete_rate*]
#   (optional) Default rate limit of DELETE request.
#   Defaults to 200.
#
# [*http_mgmt_post_rate*]
#   (optional) Default rate limit of mgmt post request.
#   Defaults to 200.
#
class trove::api(
  $keystone_password,
  $verbose                      = false,
  $debug                        = false,
  $bind_host                    = '0.0.0.0',
  $bind_port                    = '8779',
  $backlog                      = '4096',
  $workers                      = $::processorcount,
  $log_file                     = '/var/log/trove/trove-api.log',
  $log_dir                      = '/var/log/trove',
  $auth_host                    = '127.0.0.1',
  $auth_url                     = false,
  $auth_port                    = '35357',
  $auth_protocol                = 'http',
  $keystone_tenant              = 'services',
  $keystone_user                = 'trove',
  $enabled                      = true,
  $use_syslog                   = false,
  $log_facility                 = 'LOG_USER',
  $purge_config                 = false,
  $cert_file                    = false,
  $key_file                     = false,
  $ca_file                      = false,
  $http_get_rate                = 200,
  $http_post_rate               = 200,
  $http_put_rate                = 200,
  $http_delete_rate             = 200,
  $http_mgmt_post_rate          = 200,
  $manage_service               = true,
  $ensure_package               = 'present',
) inherits trove {

  require ::keystone::python
  include ::trove::db
  include ::trove::params

  Trove_config<||> ~> Exec['post-trove_config']
  Trove_config<||> ~> Service['trove-api']
  Trove_api_paste_ini<||> ~> Service['trove-api']

  # basic service config
  trove_config {
    'DEFAULT/verbose':                      value => $verbose;
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/bind_host':                    value => $bind_host;
    'DEFAULT/bind_port':                    value => $bind_port;
    'DEFAULT/backlog':                      value => $backlog;
    'DEFAULT/trove_api_workers':            value => $workers;
    'DEFAULT/nova_proxy_admin_user':        value => $::trove::nova_proxy_admin_user;
    'DEFAULT/nova_proxy_admin_pass':        value => $::trove::nova_proxy_admin_pass;
    'DEFAULT/nova_proxy_admin_tenant_name': value => $::trove::nova_proxy_admin_tenant_name;
    'DEFAULT/control_exchange':             value => $::trove::control_exchange;
    'DEFAULT/rpc_backend':                  value => $::trove::rpc_backend;
  }

  if $auth_url {
    trove_config { 'DEFAULT/trove_auth_url': value => $auth_url; }
  } else {
    trove_config { 'DEFAULT/trove_auth_url': value => "${auth_protocol}://${auth_host}:5000/v2.0"; }
  }

  # auth config
  trove_config {
    'keystone_authtoken/auth_host':         value => $auth_host;
    'keystone_authtoken/auth_port':         value => $auth_port;
    'keystone_authtoken/auth_protocol':     value => $auth_protocol;
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
  }

  # SSL Options
  if $cert_file {
    trove_config {
      'DEFAULT/cert_file' : value => $cert_file;
    }
  } else {
    trove_config {
      'DEFAULT/cert_file': ensure => absent;
    }
  }
  if $key_file {
    trove_config {
      'DEFAULT/key_file'  : value => $key_file;
    }
  } else {
    trove_config {
      'DEFAULT/key_file': ensure => absent;
    }
  }
  if $ca_file {
    trove_config {
      'DEFAULT/ca_file'   : value => $ca_file;
    }
  } else {
    trove_config {
      'DEFAULT/ca_file': ensure => absent;
    }
  }

  # Logging
  if $log_file {
    trove_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    trove_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    trove_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    trove_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    trove_config {
      'DEFAULT/use_syslog'          : value => true;
      'DEFAULT/syslog_log_facility' : value => $log_facility;
    }
  } else {
    trove_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  # rate limits
  trove_config {
    'DEFAULT/http_get_rate':       value => $http_get_rate;
    'DEFAULT/http_post_rate':      value => $http_post_rate;
    'DEFAULT/http_put_rate':       value => $http_put_rate;
    'DEFAULT/http_delete_rate':    value => $http_delete_rate;
    'DEFAULT/http_mgmt_post_rate': value => $http_mgmt_post_rate;
  }

  resources { 'trove_config':
    purge => $purge_config,
  }

  # region name
  if $::trove::os_region_name {
    trove_config { 'DEFAULT/os_region_name': value => $::trove::os_region_name }
  }
  else {
    trove_config {'DEFAULT/os_region_name': ensure => absent }
  }

  # services type
  trove_config {
    'DEFAULT/nova_compute_service_type': value => $::trove::nova_compute_service_type;
    'DEFAULT/cinder_service_type':       value => $::trove::cinder_service_type;
    'DEFAULT/neutron_service_type':      value => $::trove::neutron_service_type;
    'DEFAULT/swift_service_type':        value => $::trove::swift_service_type;
    'DEFAULT/heat_service_type':         value => $::trove::heat_service_type;
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_kombu' or $::trove::rpc_backend == 'rabbit' {
    if ! $::trove::rabbit_password {
      fail('When rpc_backend is rabbitmq, you must set rabbit password')
    }
    if $::trove::rabbit_hosts {
      trove_config { 'oslo_messaging_rabbit/rabbit_hosts':     value  => join($::trove::rabbit_hosts, ',') }
      trove_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value  => true }
    } else  {
      trove_config { 'oslo_messaging_rabbit/rabbit_host':      value => $::trove::rabbit_host }
      trove_config { 'oslo_messaging_rabbit/rabbit_port':      value => $::trove::rabbit_port }
      trove_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => "${::trove::rabbit_host}:${::trove::rabbit_port}" }
      trove_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
    }

    trove_config {
      'oslo_messaging_rabbit/rabbit_userid':         value => $::trove::rabbit_userid;
      'oslo_messaging_rabbit/rabbit_password':       value => $::trove::rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_virtual_host':   value => $::trove::rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':        value => $::trove::rabbit_use_ssl;
      'oslo_messaging_rabbit/kombu_reconnect_delay': value => $::trove::kombu_reconnect_delay;
    }

    if $::trove::rabbit_use_ssl {

      if $::trove::kombu_ssl_ca_certs {
        trove_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $::trove::kombu_ssl_ca_certs; }
      } else {
        trove_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $::trove::kombu_ssl_certfile or $::trove::kombu_ssl_keyfile {
        trove_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $::trove::kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $::trove::kombu_ssl_keyfile;
        }
      } else {
        trove_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $::trove::kombu_ssl_version {
        trove_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $::trove::kombu_ssl_version; }
      } else {
        trove_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      trove_config {
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
      }
    }
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_qpid' or $::trove::rpc_backend == 'qpid'{
    trove_config {
      'oslo_messaging_qpid/qpid_hostname':               value => $::trove::qpid_hostname;
      'oslo_messaging_qpid/qpid_port':                   value => $::trove::qpid_port;
      'oslo_messaging_qpid/qpid_username':               value => $::trove::qpid_username;
      'oslo_messaging_qpid/qpid_password':               value => $::trove::qpid_password, secret => true;
      'oslo_messaging_qpid/qpid_heartbeat':              value => $::trove::qpid_heartbeat;
      'oslo_messaging_qpid/qpid_protocol':               value => $::trove::qpid_protocol;
      'oslo_messaging_qpid/qpid_tcp_nodelay':            value => $::trove::qpid_tcp_nodelay;
    }
    if is_array($::trove::qpid_sasl_mechanisms) {
      trove_config {
        'oslo_messaging_qpid/qpid_sasl_mechanisms': value => join($::trove::qpid_sasl_mechanisms, ' ');
      }
    }
    elsif $::trove::qpid_sasl_mechanisms {
      trove_config {
        'oslo_messaging_qpid/qpid_sasl_mechanisms': value => $::trove::qpid_sasl_mechanisms;
      }
    }
    else {
      trove_config {
        'oslo_messaging_qpid/qpid_sasl_mechanisms': ensure => absent;
      }
    }
  }

  trove::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $manage_service,
    ensure_package => $ensure_package,
    package_name   => $::trove::params::api_package_name,
    service_name   => $::trove::params::api_service_name,
  }
}
