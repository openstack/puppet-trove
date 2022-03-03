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

# trove::init
#
# Trove base config
#
# == Parameters
#
# [*default_transport_url*]
#    (optional) A URL representing the messaging driver to use and its full
#    configuration. Transport URLs take the form:
#      transport://user:pass@host1:port[,hostN:portN]/virtual_host
#    Defaults to $::os_service_default
#
# [*notification_transport_url*]
#   (optional) A URL representing the messaging driver to use for
#   notifications and its full configuration. Transport URLs
#   take the form:
#      transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default.
#
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to $::os_service_default
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to $::os_service_default
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to $::os_service_default
#
# [*rabbit_notification_topic*]
#   (optional) Notification topic.
#   Defaults to $::os_service_default
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $::os_service_default
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ (x-ha-policy: all).
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_in_pthread*]
#   (Optional) EXPERIMENTAL: Run the health check heartbeat thread
#   through a native python thread. By default if this
#   option isn't provided the  health check heartbeat will
#   inherit the execution model from the parent process. By
#   example if the parent process have monkey patched the
#   stdlib by using eventlet/greenlet then the heartbeat
#   will be run through a green thread.
#   Defaults to $::os_service_default
#
# [*kombu_reconnect_delay*]
#   (optional) How long to wait before reconnecting in response to an AMQP
#   consumer cancel notification.
#   Defaults to $::os_service_default
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $::os_service_default
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to $::os_service_default
#
# [*amqp_server_request_prefix*]
#   (Optional) Address prefix used when sending to a specific server
#   Defaults to $::os_service_default.
#
# [*amqp_broadcast_prefix*]
#   (Optional) address prefix used when broadcasting to all servers
#   Defaults to $::os_service_default.
#
# [*amqp_group_request_prefix*]
#   (Optional) address prefix when sending to any server in group
#   Defaults to $::os_service_default.
#
# [*amqp_container_name*]
#   (Optional) Name for the AMQP container
#   Defaults to $::os_service_default.
#
# [*amqp_idle_timeout*]
#   (Optional) Timeout for inactive connections
#   Defaults to $::os_service_default.
#
# [*amqp_trace*]
#   (Optional) Debug: dump AMQP frames to stdout
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_ca_file*]
#   (Optional) CA certificate PEM file to verify server certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_cert_file*]
#   (Optional) Identifying certificate PEM file to present to clients
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_file*]
#   (Optional) Private key PEM file used to sign cert_file certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_mechanisms*]
#   (Optional) Space separated list of acceptable SASL mechanisms
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_config_dir*]
#   (Optional) Path to directory that contains the SASL configuration
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_config_name*]
#   (Optional) Name of configuration file (without .conf suffix)
#   Defaults to $::os_service_default.
#
# [*amqp_username*]
#   (Optional) User name for message broker authentication
#   Defaults to $::os_service_default.
#
# [*amqp_password*]
#   (Optional) Password for message broker authentication
#   Defaults to $::os_service_default.
#
# [*single_tenant_mode*]
#   (optional) If set to true, will configure Trove to work in single
#   tenant mode.
#   Defaults to false.
#
# [*nova_compute_url*]
#   (optional) URL without the tenant segment.
#   Defaults to false.
#
# [*rpc_response_timeout*]
#  (Optional) Seconds to wait for a response from a call.
#  Defaults to $::os_service_default
#
# [*control_exchange*]
#   (optional) Control exchange.
#   Defaults to 'trove'.
#
# [*cinder_url*]
#   (optional) Cinder URL without the tenant segment.
#   Defaults to false.
#
# [*swift_url*]
#   (optional) Swift URL ending in AUTH_.
#   Defaults to false.
#
# [*neutron_url*]
#   (optional) Neutron URL without the tenant segment.
#   Defaults to false.
#
# [*nova_compute_service_type*]
#   (optional) Nova service type to use when searching catalog.
#   Defaults to 'compute'.
#
# [*cinder_service_type*]
#   (optional) Cinder service type to use when searching catalog.
#   Defaults to 'volumev3'.
#
# [*swift_service_type*]
#   (optional) Swift service type to use when searching catalog.
#   Defaults to 'object-store'.
#
# [*neutron_service_type*]
#   (optional) Neutron service type to use when searching catalog.
#   Defaults to 'network'.
#
# [*glance_service_type*]
#   (optional) Glance service type to use when searching catalog.
#   Defaults to 'image'.
#
# [*nova_compute_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*neutron_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*cinder_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*swift_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*glance_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*trove_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $::os_service_default
#
# [*default_neutron_networks*]
#   (optional) The network that trove will attach by default.
#   Defaults to $::os_service_default.
#
# [*package_ensure*]
#   (optional) The state of the package.
#   Defaults to 'present'
#
# DEPRECATED PARAMETERS
#
# [*use_neutron*]
#   (optional) Use Neutron
#   Defaults to undef
#
# [*database_connection*]
#   (optional) Connection url to connect to trove database.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to undef.
#
# [*database_max_retries*]
#   (optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   Defaults to undef.
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   Defaults to undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.
#
class trove(
  $default_transport_url        = $::os_service_default,
  $notification_transport_url   = $::os_service_default,
  $notification_driver          = $::os_service_default,
  $notification_topics          = $::os_service_default,
  $rabbit_use_ssl               = $::os_service_default,
  $rabbit_ha_queues             = $::os_service_default,
  $rabbit_notification_topic    = $::os_service_default,
  $rabbit_heartbeat_in_pthread  = $::os_service_default,
  $kombu_ssl_ca_certs           = $::os_service_default,
  $kombu_ssl_certfile           = $::os_service_default,
  $kombu_ssl_keyfile            = $::os_service_default,
  $kombu_ssl_version            = $::os_service_default,
  $kombu_reconnect_delay        = $::os_service_default,
  $kombu_failover_strategy      = $::os_service_default,
  $amqp_durable_queues          = $::os_service_default,
  $amqp_server_request_prefix   = $::os_service_default,
  $amqp_broadcast_prefix        = $::os_service_default,
  $amqp_group_request_prefix    = $::os_service_default,
  $amqp_container_name          = $::os_service_default,
  $amqp_idle_timeout            = $::os_service_default,
  $amqp_trace                   = $::os_service_default,
  $amqp_ssl_ca_file             = $::os_service_default,
  $amqp_ssl_cert_file           = $::os_service_default,
  $amqp_ssl_key_file            = $::os_service_default,
  $amqp_ssl_key_password        = $::os_service_default,
  $amqp_sasl_mechanisms         = $::os_service_default,
  $amqp_sasl_config_dir         = $::os_service_default,
  $amqp_sasl_config_name        = $::os_service_default,
  $amqp_username                = $::os_service_default,
  $amqp_password                = $::os_service_default,
  $single_tenant_mode           = false,
  $nova_compute_url             = false,
  $rpc_response_timeout         = $::os_service_default,
  $control_exchange             = 'trove',
  $cinder_url                   = false,
  $swift_url                    = false,
  $neutron_url                  = false,
  $nova_compute_service_type    = 'compute',
  $cinder_service_type          = 'volumev3',
  $swift_service_type           = 'object-store',
  $neutron_service_type         = 'network',
  $glance_service_type          = 'image',
  $nova_compute_endpoint_type   = $::os_service_default,
  $cinder_endpoint_type         = $::os_service_default,
  $swift_endpoint_type          = $::os_service_default,
  $glance_endpoint_type         = $::os_service_default,
  $trove_endpoint_type          = $::os_service_default,
  $neutron_endpoint_type        = $::os_service_default,
  $default_neutron_networks     = $::os_service_default,
  $package_ensure               = 'present',
  # DEPRECATED PARAMETERS
  $use_neutron                  = undef,
  $database_connection          = undef,
  $database_idle_timeout        = undef,
  $database_max_retries         = undef,
  $database_retry_interval      = undef,
  $database_max_pool_size       = undef,
  $database_max_overflow        = undef,
) {

  include trove::deps
  include trove::policy
  include trove::params

  if $use_neutron != undef {
    warning('The trove::use_neutron parameter has been deprecated and has no effect.')
  }

  [
    'database_connection',
    'database_idle_timeout',
    'database_max_retries',
    'database_retry_interval',
    'database_max_pool_size',
    'database_max_overflow'
  ].each |String $db_opt| {
    if getvar($db_opt) != undef {
      warning("The ${db_opt} parameter is deprecated. Use the parameters of trove::db.")
    }
  }

  if $nova_compute_url {
    trove_config { 'DEFAULT/nova_compute_url': value => $nova_compute_url }
  }
  else {
    trove_config { 'DEFAULT/nova_compute_url': ensure => absent }
  }

  if $cinder_url {
    trove_config { 'DEFAULT/cinder_url': value => $cinder_url }
  }
  else {
    trove_config { 'DEFAULT/cinder_url': ensure => absent }
  }

  if $swift_url {
    trove_config { 'DEFAULT/swift_url': value => $swift_url }
  }
  else {
    trove_config { 'DEFAULT/swift_url': ensure => absent }
  }

  if $neutron_url {
    trove_config { 'DEFAULT/neutron_url': value => $neutron_url }
  }
  else {
    trove_config { 'DEFAULT/neutron_url': ensure => absent }
  }

  package { 'trove':
    ensure => $package_ensure,
    name   => $::trove::params::common_package_name,
    tag    => ['openstack', 'trove-package'],
  }

  # services type
  trove_config {
    'DEFAULT/nova_compute_service_type': value => $nova_compute_service_type;
    'DEFAULT/cinder_service_type':       value => $cinder_service_type;
    'DEFAULT/neutron_service_type':      value => $neutron_service_type;
    'DEFAULT/glance_service_type':       value => $glance_service_type;
    'DEFAULT/swift_service_type':        value => $swift_service_type;
  }

  # endpoint type
  trove_config {
    'DEFAULT/nova_compute_endpoint_type': value => $nova_compute_endpoint_type;
    'DEFAULT/cinder_endpoint_type':       value => $cinder_endpoint_type;
    'DEFAULT/neutron_endpoint_type':      value => $neutron_endpoint_type;
    'DEFAULT/swift_endpoint_type':        value => $swift_endpoint_type;
    'DEFAULT/glance_endpoint_type':       value => $glance_endpoint_type;
    'DEFAULT/trove_endpoint_type':        value => $trove_endpoint_type;
  }

  if $single_tenant_mode {
    trove_config {
      'DEFAULT/remote_nova_client':    value => 'trove.common.single_tenant_remote.nova_client_trove_admin';
      'DEFAULT/remote_cinder_client':  value => 'trove.common.single_tenant_remote.cinder_client_trove_admin';
      'DEFAULT/remote_neutron_client': value => 'trove.common.single_tenant_remote.neutron_client_trove_admin';
    }
  }
  else {
    trove_config {
      'DEFAULT/remote_nova_client':    ensure => absent;
      'DEFAULT/remote_cinder_client':  ensure => absent;
      'DEFAULT/remote_neutron_client': ensure => absent;
    }
  }

  trove_config {
    'DEFAULT/network_label_regex':      value => '.*';
    'DEFAULT/network_driver':           value => 'trove.network.neutron.NeutronDriver';
    'DEFAULT/default_neutron_networks': value => $default_neutron_networks;
  }

  oslo::messaging::default { 'trove_config':
    transport_url        => $default_transport_url,
    control_exchange     => $control_exchange,
    rpc_response_timeout => $rpc_response_timeout,
  }

  oslo::messaging::notifications { 'trove_config':
    transport_url => $notification_transport_url,
    driver        => $notification_driver,
    topics        => $notification_topics
  }

  oslo::messaging::rabbit { 'trove_config':
    rabbit_ha_queues        => $rabbit_ha_queues,
    rabbit_use_ssl          => $rabbit_use_ssl,
    kombu_reconnect_delay   => $kombu_reconnect_delay,
    kombu_failover_strategy => $kombu_failover_strategy,
    amqp_durable_queues     => $amqp_durable_queues,
    kombu_ssl_ca_certs      => $kombu_ssl_ca_certs,
    kombu_ssl_certfile      => $kombu_ssl_certfile,
    kombu_ssl_keyfile       => $kombu_ssl_keyfile,
    kombu_ssl_version       => $kombu_ssl_version
  }

  oslo::messaging::amqp { 'trove_config':
    server_request_prefix => $amqp_server_request_prefix,
    broadcast_prefix      => $amqp_broadcast_prefix,
    group_request_prefix  => $amqp_group_request_prefix,
    container_name        => $amqp_container_name,
    idle_timeout          => $amqp_idle_timeout,
    trace                 => $amqp_trace,
    ssl_ca_file           => $amqp_ssl_ca_file,
    ssl_cert_file         => $amqp_ssl_cert_file,
    ssl_key_file          => $amqp_ssl_key_file,
    ssl_key_password      => $amqp_ssl_key_password,
    sasl_mechanisms       => $amqp_sasl_mechanisms,
    sasl_config_dir       => $amqp_sasl_config_dir,
    sasl_config_name      => $amqp_sasl_config_name,
    username              => $amqp_username,
    password              => $amqp_password,
  }
}
