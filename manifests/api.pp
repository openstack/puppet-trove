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
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Defaults to undef
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Defaults to undef
#
# [*log_dir*]
#   (optional) directory to which trove logs are sent.
#   If set to boolean false, it will not log to any directory.
#   Defaults to undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to undef
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef.
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
# [*auth_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to false.
#
# [*identity_uri*]
#   (Optional) Complete admin Identity API endpoint.
#   This should specify the unversioned root endpoint.
#   Defaults to false.
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
# == DEPRECATED PARAMETERS
#
# [*auth_host*]
#   (optional) DEPRECATED: Use identity_uri instead.
#   Host running auth service.
#   Defaults to '127.0.0.1.
#
# [*auth_port*]
#   (optional) DEPRECATED: Use identity_uri instead.
#   Port to use for auth service on auth_host.
#   Defaults to '35357'.
#
# [*auth_protocol*]
#   (optional) DEPRECATED: Use identity_uri instead.
#   Protocol to use for auth.
#   Defaults to 'http'.
#
# [*auth_url*]
#   (optional) DEPRECATED: Use auth_uri instead.
#   Authentication URL.
#   Defaults to 'http://localhost:5000/v2.0'.
#
# [*verbose*]
#   (optional) Deprecated. Rather to log the trove api service at verbose level.
#   Defaults to undef
#
class trove::api(
  $keystone_password,
  $debug                        = undef,
  $log_file                     = undef,
  $log_dir                      = undef,
  $use_syslog                   = undef,
  $use_stderr                   = undef,
  $log_facility                 = undef,
  $bind_host                    = '0.0.0.0',
  $bind_port                    = '8779',
  $backlog                      = '4096',
  $workers                      = $::processorcount,
  $auth_uri                     = false,
  $identity_uri                 = false,
  $keystone_tenant              = 'services',
  $keystone_user                = 'trove',
  $enabled                      = true,
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
  # DEPRECATED PARAMETERS
  $auth_host                    = '127.0.0.1',
  $auth_url                     = 'http://localhost:5000/v2.0',
  $auth_port                    = '35357',
  $auth_protocol                = 'http',
  $verbose                      = undef,
) inherits trove {

  include ::trove::deps
  include ::trove::db
  include ::trove::db::sync
  include ::trove::logging
  include ::trove::params

  if $verbose {
    warning('verbose is deprecated, has no effect and will be removed after Newton cycle.')
  }

  # basic service config
  trove_config {
    'DEFAULT/bind_host':                    value => $bind_host;
    'DEFAULT/bind_port':                    value => $bind_port;
    'DEFAULT/backlog':                      value => $backlog;
    'DEFAULT/trove_api_workers':            value => $workers;
    'DEFAULT/nova_proxy_admin_user':        value => $::trove::nova_proxy_admin_user;
    'DEFAULT/nova_proxy_admin_pass':        value => $::trove::nova_proxy_admin_pass;
    'DEFAULT/nova_proxy_admin_tenant_name': value => $::trove::nova_proxy_admin_tenant_name;
  }

  oslo::messaging::default { 'trove_config':
    transport_url    => $::trove::default_transport_url,
    control_exchange => $::trove::control_exchange
  }

  if $identity_uri {
    trove_config { 'keystone_authtoken/identity_uri': value => $identity_uri; }
  } else {
    trove_config { 'keystone_authtoken/identity_uri': ensure => absent; }
  }

  if $auth_uri {
    trove_config {
      'DEFAULT/trove_auth_url'      : value => $auth_uri;
      'keystone_authtoken/auth_uri' : value => $auth_uri;
    }
  } else {
    if $auth_url {
      warning('The auth_url parameter is deprecated. Please use auth_uri instead.')
      trove_config {
        'DEFAULT/trove_auth_url'      : value => $auth_url;
        'keystone_authtoken/auth_uri' : value => $auth_url;
      }
    } else {
      $auth_uri_real = "${auth_protocol}://${auth_host}:5000/v2.0"
      warning('In a next release, auth_uri will be default to version-less keystone endpoint.')
      trove_config {
        'DEFAULT/trove_auth_url'      : value => $auth_uri_real;
        'keystone_authtoken/auth_uri' : value => $auth_uri_real;
      }
    }
  }


  # if both auth_uri and identity_uri are set we skip these deprecated settings entirely
  if !$auth_uri or !$identity_uri {

    if $auth_host {
      warning('The auth_host parameter is deprecated. Please use auth_uri and identity_uri instead.')
      trove_config { 'keystone_authtoken/auth_host': value => $auth_host; }
    } else {
      trove_config { 'keystone_authtoken/auth_host': ensure => absent; }
    }

    if $auth_port {
      warning('The auth_port parameter is deprecated. Please use auth_uri and identity_uri instead.')
      trove_config { 'keystone_authtoken/auth_port': value => $auth_port; }
    } else {
      trove_config { 'keystone_authtoken/auth_port': ensure => absent; }
    }

    if $auth_protocol {
      warning('The auth_protocol parameter is deprecated. Please use auth_uri and identity_uri instead.')
      trove_config { 'keystone_authtoken/auth_protocol': value => $auth_protocol; }
    } else {
      trove_config { 'keystone_authtoken/auth_protocol': ensure => absent; }
    }

  } else {
    trove_config {
      'keystone_authtoken/auth_host'         : ensure => absent;
      'keystone_authtoken/auth_port'         : ensure => absent;
      'keystone_authtoken/auth_protocol'     : ensure => absent;
    }
  }

  trove_config {
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
  }

  # SSL Options
  if $cert_file {
    trove_config {
      'ssl/cert_file' : value => $cert_file;
    }
  } else {
    trove_config {
      'ssl/cert_file': ensure => absent;
    }
  }
  if $key_file {
    trove_config {
      'ssl/key_file'  : value => $key_file;
    }
  } else {
    trove_config {
      'ssl/key_file': ensure => absent;
    }
  }
  if $ca_file {
    trove_config {
      'ssl/ca_file'   : value => $ca_file;
    }
  } else {
    trove_config {
      'ssl/ca_file': ensure => absent;
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

  oslo::messaging::notifications { 'trove_config':
    transport_url => $::trove::notification_transport_url,
    driver        => $::trove::notification_driver,
    topics        => $::trove::notification_topics
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_kombu' or $::trove::rpc_backend == 'rabbit' {
    oslo::messaging::rabbit {'trove_config':
      rabbit_hosts          => $::trove::rabbit_hosts,
      rabbit_host           => $::trove::rabbit_host,
      rabbit_port           => $::trove::rabbit_port,
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
  } elsif $::trove::rpc_backend == 'amqp' {
    oslo::messaging::amqp { 'trove_config':
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
  } else {
    trove_config {
      'DEFAULT/rpc_backend' : value => $::trove::rpc_backend;
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
