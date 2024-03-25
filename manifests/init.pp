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
#    Defaults to $facts['os_service_default']
#
# [*notification_transport_url*]
#   (optional) A URL representing the messaging driver to use for
#   notifications and its full configuration. Transport URLs
#   take the form:
#      transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $facts['os_service_default'].
#
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to $facts['os_service_default']
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to $facts['os_service_default']
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to $facts['os_service_default']
#
# [*rabbit_notification_topic*]
#   (optional) Notification topic.
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ (x-ha-policy: all).
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_rate*]
#   (optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_in_pthread*]
#   (Optional) EXPERIMENTAL: Run the health check heartbeat thread
#   through a native python thread. By default if this
#   option isn't provided the  health check heartbeat will
#   inherit the execution model from the parent process. By
#   example if the parent process have monkey patched the
#   stdlib by using eventlet/greenlet then the heartbeat
#   will be run through a green thread.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_queue*]
#   (Optional) Use quorum queues in RabbitMQ.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_transient_quorum_queue*]
#   (Optional) Use quorum queues for transients queues in RabbitMQ.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_delivery_limit*]
#   (Optional) Each time a message is rdelivered to a consumer, a counter is
#   incremented. Once the redelivery count exceeds the delivery limit
#   the message gets dropped or dead-lettered.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_max_memory_length*]
#   (Optional) Limit the number of messages in the quorum queue.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_max_memory_bytes*]
#   (Optional) Limit the number of memory bytes used by the quorum queue.
#   Defaults to $facts['os_service_default']
#
# [*kombu_reconnect_delay*]
#   (optional) How long to wait before reconnecting in response to an AMQP
#   consumer cancel notification.
#   Defaults to $facts['os_service_default']
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $facts['os_service_default']
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to $facts['os_service_default']
#
# [*amqp_server_request_prefix*]
#   (Optional) Address prefix used when sending to a specific server
#   Defaults to $facts['os_service_default'].
#
# [*amqp_broadcast_prefix*]
#   (Optional) address prefix used when broadcasting to all servers
#   Defaults to $facts['os_service_default'].
#
# [*amqp_group_request_prefix*]
#   (Optional) address prefix when sending to any server in group
#   Defaults to $facts['os_service_default'].
#
# [*amqp_container_name*]
#   (Optional) Name for the AMQP container
#   Defaults to $facts['os_service_default'].
#
# [*amqp_idle_timeout*]
#   (Optional) Timeout for inactive connections
#   Defaults to $facts['os_service_default'].
#
# [*amqp_trace*]
#   (Optional) Debug: dump AMQP frames to stdout
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_ca_file*]
#   (Optional) CA certificate PEM file to verify server certificate
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_cert_file*]
#   (Optional) Identifying certificate PEM file to present to clients
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_key_file*]
#   (Optional) Private key PEM file used to sign cert_file certificate
#   Defaults to $facts['os_service_default'].
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $facts['os_service_default'].
#
# [*amqp_sasl_mechanisms*]
#   (Optional) Space separated list of acceptable SASL mechanisms
#   Defaults to $facts['os_service_default'].
#
# [*amqp_sasl_config_dir*]
#   (Optional) Path to directory that contains the SASL configuration
#   Defaults to $facts['os_service_default'].
#
# [*amqp_sasl_config_name*]
#   (Optional) Name of configuration file (without .conf suffix)
#   Defaults to $facts['os_service_default'].
#
# [*amqp_username*]
#   (Optional) User name for message broker authentication
#   Defaults to $facts['os_service_default'].
#
# [*amqp_password*]
#   (Optional) Password for message broker authentication
#   Defaults to $facts['os_service_default'].
#
# [*rpc_response_timeout*]
#  (Optional) Seconds to wait for a response from a call.
#  Defaults to $facts['os_service_default']
#
# [*control_exchange*]
#   (optional) Control exchange.
#   Defaults to 'trove'.
#
# [*nova_compute_url*]
#   (optional) URL without the tenant segment.
#   Defaults to $facts['os_service_default'].
#
# [*cinder_url*]
#   (optional) Cinder URL without the tenant segment.
#   Defaults to $facts['os_service_default'].
#
# [*swift_url*]
#   (optional) Swift URL ending in AUTH_.
#   Defaults to $facts['os_service_default'].
#
# [*neutron_url*]
#   (optional) Neutron URL without the tenant segment.
#   Defaults to $facts['os_service_default'].
#
# [*glance_url*]
#   (optional) Glance URL without the tenant segment.
#   Defaults to $facts['os_service_default'].
#
# [*nova_compute_service_type*]
#   (optional) Nova service type to use when searching catalog.
#   Defaults to $facts['os_service_default'].
#
# [*cinder_service_type*]
#   (optional) Cinder service type to use when searching catalog.
#   Defaults to $facts['os_service_default'].
#
# [*swift_service_type*]
#   (optional) Swift service type to use when searching catalog.
#   Defaults to $facts['os_service_default'].
#
# [*neutron_service_type*]
#   (optional) Neutron service type to use when searching catalog.
#   Defaults to $facts['os_service_default'].
#
# [*glance_service_type*]
#   (optional) Glance service type to use when searching catalog.
#   Defaults to $facts['os_service_default'].
#
# [*nova_compute_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*neutron_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*cinder_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*swift_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*glance_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*trove_endpoint_type*]
#   (optional) Service endpoint type to use when searching catalog.
#   Defaults to $facts['os_service_default']
#
# [*management_networks*]
#   (optional) The network that trove will attach by default.
#   Defaults to $facts['os_service_default'].
#
# [*trove_volume_support*]
#   (optional) Whether to provision a Cinder volume for datadir.
#   Defaults to $facts['os_service_default'].
#
# [*volume_rootdisk_support*]
#   (optional) Whether to provision a Cinder volume for rootdisk.
#   Defaults to $facts['os_service_default'].
#
# [*volume_rootdisk_size*]
#   (optional) Size of volume rootdisk for Database instance.
#   Defaults to $facts['os_service_default'].
#
# [*package_ensure*]
#   (optional) The state of the package.
#   Defaults to 'present'
#
# DEPRECATED PARAMETERS
#
# [*single_tenant_mode*]
#   (optional) If set to true, will configure Trove to work in single
#   tenant mode.
#   Defaults to undef.
#
class trove(
  $default_transport_url              = $facts['os_service_default'],
  $notification_transport_url         = $facts['os_service_default'],
  $notification_driver                = $facts['os_service_default'],
  $notification_topics                = $facts['os_service_default'],
  $rabbit_use_ssl                     = $facts['os_service_default'],
  $rabbit_ha_queues                   = $facts['os_service_default'],
  $rabbit_notification_topic          = $facts['os_service_default'],
  $rabbit_heartbeat_timeout_threshold = $facts['os_service_default'],
  $rabbit_heartbeat_rate              = $facts['os_service_default'],
  $rabbit_heartbeat_in_pthread        = $facts['os_service_default'],
  $rabbit_quorum_queue                = $facts['os_service_default'],
  $rabbit_transient_quorum_queue      = $facts['os_service_default'],
  $rabbit_quorum_delivery_limit       = $facts['os_service_default'],
  $rabbit_quorum_max_memory_length    = $facts['os_service_default'],
  $rabbit_quorum_max_memory_bytes     = $facts['os_service_default'],
  $kombu_ssl_ca_certs                 = $facts['os_service_default'],
  $kombu_ssl_certfile                 = $facts['os_service_default'],
  $kombu_ssl_keyfile                  = $facts['os_service_default'],
  $kombu_ssl_version                  = $facts['os_service_default'],
  $kombu_reconnect_delay              = $facts['os_service_default'],
  $kombu_failover_strategy            = $facts['os_service_default'],
  $amqp_durable_queues                = $facts['os_service_default'],
  $amqp_server_request_prefix         = $facts['os_service_default'],
  $amqp_broadcast_prefix              = $facts['os_service_default'],
  $amqp_group_request_prefix          = $facts['os_service_default'],
  $amqp_container_name                = $facts['os_service_default'],
  $amqp_idle_timeout                  = $facts['os_service_default'],
  $amqp_trace                         = $facts['os_service_default'],
  $amqp_ssl_ca_file                   = $facts['os_service_default'],
  $amqp_ssl_cert_file                 = $facts['os_service_default'],
  $amqp_ssl_key_file                  = $facts['os_service_default'],
  $amqp_ssl_key_password              = $facts['os_service_default'],
  $amqp_sasl_mechanisms               = $facts['os_service_default'],
  $amqp_sasl_config_dir               = $facts['os_service_default'],
  $amqp_sasl_config_name              = $facts['os_service_default'],
  $amqp_username                      = $facts['os_service_default'],
  $amqp_password                      = $facts['os_service_default'],
  $rpc_response_timeout               = $facts['os_service_default'],
  $control_exchange                   = 'trove',
  $nova_compute_url                   = $facts['os_service_default'],
  $cinder_url                         = $facts['os_service_default'],
  $swift_url                          = $facts['os_service_default'],
  $neutron_url                        = $facts['os_service_default'],
  $glance_url                         = $facts['os_service_default'],
  $nova_compute_service_type          = $facts['os_service_default'],
  $cinder_service_type                = $facts['os_service_default'],
  $swift_service_type                 = $facts['os_service_default'],
  $neutron_service_type               = $facts['os_service_default'],
  $glance_service_type                = $facts['os_service_default'],
  $nova_compute_endpoint_type         = $facts['os_service_default'],
  $cinder_endpoint_type               = $facts['os_service_default'],
  $swift_endpoint_type                = $facts['os_service_default'],
  $glance_endpoint_type               = $facts['os_service_default'],
  $trove_endpoint_type                = $facts['os_service_default'],
  $neutron_endpoint_type              = $facts['os_service_default'],
  $management_networks                = $facts['os_service_default'],
  $trove_volume_support               = $facts['os_service_default'],
  $volume_rootdisk_support            = $facts['os_service_default'],
  $volume_rootdisk_size               = $facts['os_service_default'],
  $package_ensure                     = 'present',
  # DEPRECATED PARAMETERS
  $single_tenant_mode                 = undef,
) {

  include trove::deps
  include trove::policy
  include trove::params

  if $single_tenant_mode != undef {
    warning('The single_tenant_mode parameter is deprecated and has no effect.')
  }

  package { 'trove':
    ensure => $package_ensure,
    name   => $::trove::params::common_package_name,
    tag    => ['openstack', 'trove-package'],
  }

  # endpoint url
  trove_config {
    'DEFAULT/nova_compute_url': value => $nova_compute_url;
    'DEFAULT/cinder_url':       value => $cinder_url;
    'DEFAULT/swift_url':        value => $swift_url;
    'DEFAULT/neutron_url':      value => $neutron_url;
    'DEFAULT/glance_url':       value => $glance_url;
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

  # network
  trove_config {
    'DEFAULT/network_label_regex': value => '.*';
    'DEFAULT/network_driver':      value => 'trove.network.neutron.NeutronDriver';
    'DEFAULT/management_networks': value => join(any2array($management_networks), ',');
  }

  # volume
  trove_config {
    'DEFAULT/trove_volume_support':    value => $trove_volume_support;
    'DEFAULT/volume_rootdisk_support': value => $volume_rootdisk_support;
    'DEFAULT/volume_rootdisk_size':    value => $volume_rootdisk_size;
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
    rabbit_ha_queues                => $rabbit_ha_queues,
    heartbeat_timeout_threshold     => $rabbit_heartbeat_timeout_threshold,
    heartbeat_rate                  => $rabbit_heartbeat_rate,
    heartbeat_in_pthread            => $rabbit_heartbeat_in_pthread,
    rabbit_use_ssl                  => $rabbit_use_ssl,
    kombu_reconnect_delay           => $kombu_reconnect_delay,
    kombu_failover_strategy         => $kombu_failover_strategy,
    amqp_durable_queues             => $amqp_durable_queues,
    kombu_ssl_ca_certs              => $kombu_ssl_ca_certs,
    kombu_ssl_certfile              => $kombu_ssl_certfile,
    kombu_ssl_keyfile               => $kombu_ssl_keyfile,
    kombu_ssl_version               => $kombu_ssl_version,
    rabbit_quorum_queue             => $rabbit_quorum_queue,
    rabbit_transient_quorum_queue   => $rabbit_transient_quorum_queue,
    rabbit_quorum_delivery_limit    => $rabbit_quorum_delivery_limit,
    rabbit_quorum_max_memory_length => $rabbit_quorum_max_memory_length,
    rabbit_quorum_max_memory_bytes  => $rabbit_quorum_max_memory_bytes,
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
