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
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Defaults to undef
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $::os_service_default, it will not log to any file.
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
# [*auth_strategy*]
#   (optional) The strategy to use for authentication.
#   Defaults to 'keystone'
#
# == DEPRECATED PARAMETERS
#
# [*keystone_tenant*]
#   (optional) Deprecated. Use trove::keystone::authtoken::project_name instead.
#   Defaults to undef.
#
# [*keystone_user*]
#   (optional) Deprecated. Use trove::keystone::authtoken::username instead.
#   Defaults to undef.
#
# [*keystone_password*]
#   (optional) Deprecated. Use trove::keystone::authtoken::password instead.
#   Defaults to undef.
#
# [*identity_uri*]
#   (optional) Deprecated. Use trove::keystone::authtoken::auth_url instead.
#   Defaults to undef.
#
# [*auth_uri*]
#   (Optional) Deprecated. Use trove::keystone::authtoken::auth_uri instead.
#   Defaults to undef.
#
# [*verbose*]
#   (optional) Deprecated. Rather to log the trove api service at verbose level.
#   Defaults to undef
#
# [*auth_url*]
#   (optional) Deprecated. Use trove::keystone::authtoken::auth_url instead.
#   Defaults to undef
#
class trove::api(
  $debug                          = undef,
  $log_file                       = undef,
  $log_dir                        = undef,
  $use_syslog                     = undef,
  $use_stderr                     = undef,
  $log_facility                   = undef,
  $bind_host                      = '0.0.0.0',
  $bind_port                      = '8779',
  $backlog                        = '4096',
  $workers                        = $::processorcount,
  $enabled                        = true,
  $purge_config                   = false,
  $cert_file                      = false,
  $key_file                       = false,
  $ca_file                        = false,
  $http_get_rate                  = 200,
  $http_post_rate                 = 200,
  $http_put_rate                  = 200,
  $http_delete_rate               = 200,
  $http_mgmt_post_rate            = 200,
  $manage_service                 = true,
  $ensure_package                 = 'present',
  $auth_strategy                  = 'keystone',
  # DEPRECATED PARAMETERS
  $keystone_password              = undef,
  $keystone_tenant                = undef,
  $keystone_user                  = undef,
  $identity_uri                   = undef,
  $auth_uri                       = undef,
  $verbose                        = undef,
  $auth_url                       = undef,
) inherits trove {

  include ::trove::deps
  include ::trove::db
  include ::trove::db::sync
  include ::trove::logging
  include ::trove::params

  if $keystone_password {
    warning('keystone_password is deprecated, use trove::keystone::authtoken::password instead.')
  }

  if $keystone_tenant {
    warning('keystone_password is deprecated, use trove::keystone::authtoken::project_name instead.')
  }

  if $keystone_user {
    warning('keystone_password is deprecated, use trove::keystone::authtoken::username instead.')
  }

  if $identity_uri {
    warning('keystone_password is deprecated, use trove::keystone::authtoken::auth_url instead.')
  }

  if $auth_uri {
    warning('keystone_password is deprecated, use trove::keystone::authtoken::auth_uri instead.')
  }

  if $verbose {
    warning('verbose is deprecated, has no effect and will be removed after Newton cycle.')
  }

  if $auth_url {
    warning('auth_url is deprecated, use trove::keystone::authtoken::auth_url instead.')
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

  if $auth_strategy == 'keystone' {
    include ::trove::keystone::authtoken

    trove_config {
      'DEFAULT/trove_auth_url' : value => pick($auth_uri,$::trove::keystone::authtoken::auth_uri);
    }
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
