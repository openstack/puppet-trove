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
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to noop
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to 'notifications'
#
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#   Note that, for security reasons, this rabbitmq host should not be the
#   same that the core openstack services are using for communication. See
#   http://lists.openstack.org/pipermail/openstack-dev/2015-April/061759.html
#   Defaults to 'localhost'
#
# [*rabbit_hosts*]
#   (optional) List of clustered rabbit servers.
#   Note that, for security reasons, these rabbitmq hosts should not be the
#   same that the core openstack services are using for communication. See
#   http://lists.openstack.org/pipermail/openstack-dev/2015-April/061759.html
#   Defaults to false
#
# [*rabbit_port*]
#   (optional) Port for rabbitmq instance.
#   Defaults to '5672'
#
# [*rabbit_password*]
#   (optional) Password used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_userid*]
#   (optional) User used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_virtual_host*]
#   (optional) The RabbitMQ virtual host.
#   Defaults to '/'
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to false
#
# [*rabbit_notification_topic*]
#   (optional) Notification topic.
#   Defaults to false.
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to 'TLSv1'
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ (x-ha-policy: all).
#   Defaults to undef
#
# [*kombu_reconnect_delay*]
#   (optional) How long to wait before reconnecting in response to an AMQP
#   consumer cancel notification.
#   Defaults to $::os_service_default
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to false
#
# [*rpc_backend*]
#   (optional) The rpc backend implementation to use, can be:
#     rabbit (for rabbitmq)
#     qpid  (for qpid)
#   Defaults to 'rabbit'
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
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.
#
# [*nova_compute_url*]
#   (optional) URL without the tenant segment.
#   Defaults to false.
#
# [*nova_proxy_admin_user*]
#   (optional) Admin username used to connect to nova.
#   Defaults to 'admin'
#
# [*nova_proxy_admin_pass*]
#   (required) Admin password used to connect to nova.
#
# [*nova_proxy_admin_tenant_name*]
#   (optional) Admin tenant name used to connect to nova.
#   Defaults to 'admin'
#
# [*control_exchange*]
#   (optional) Control exchange.
#   Defaults to 'trove'.
#
# [*cinder_url*]
#   (optional) URL without the tenant segment.
#   Defaults to false.
#
# [*swift_url*]
#   (optional) Swift URL ending in AUTH_.
#   Defaults to false.
#
# [*neutron_url*]
#   (optional) Cinder URL without the tenant segment.
#   Defaults to false.
#
# [*os_region_name*]
#   (optional) Sets the os_region_name flag. For environments with
#   more than one endpoint per service. If you don't set this and
#   you have multiple endpoints, you will get Ambiguous Endpoint
#   exceptions in the trove API service.
#   Defaults to undef.
#
# [*nova_compute_service_type*]
#   (optional) Nova service type to use when searching catalog.
#   Defaults to 'compute'.
#
# [*cinder_service_type*]
#   (optional) Cinder service type to use when searching catalog.
#   Defaults to 'volumev2'.
#
# [*swift_service_type*]
#   (optional) Swift service type to use when searching catalog.
#   Defaults to 'object-store'.
#
# [*heat_service_type*]
#   (optional) Heat service type to use when searching catalog.
#   Defaults to 'orchestration'.
#
# [*neutron_service_type*]
#   (optional) Neutron service type to use when searching catalog.
#   Defaults to 'network'.
#
# [*use_neutron*]
#   (optional) Use Neutron
#   Defaults to true
#
# [*package_ensure*]
#   (optional) The state of the package.
#   Defaults to 'present'
#
# DEPRECATED PARAMETERS
#
# [*qpid_hostname*]
#   (optional) Location of qpid server
#   Defaults to undef
#
# [*qpid_port*]
#   (optional) Port for qpid server
#   Defaults to undef
#
# [*qpid_username*]
#   (optional) Username to use when connecting to qpid
#   Defaults to undef
#
# [*qpid_password*]
#   (optional) Password to use when connecting to qpid
#   Defaults to undef
#
# [*qpid_heartbeat*]
#   (optional) Seconds between connection keepalive heartbeats
#   Defaults to undef
#
# [*qpid_protocol*]
#   (optional) Transport to use, either 'tcp' or 'ssl''
#   Defaults to undef
#
# [*qpid_sasl_mechanisms*]
#   (optional) Enable one or more SASL mechanisms
#   Defaults to undef
#
# [*qpid_tcp_nodelay*]
#   (optional) Disable Nagle algorithm
#   Defaults to undef
#
class trove(
  $nova_proxy_admin_pass,
  $notification_driver          = 'noop',
  $notification_topics          = 'notifications',
  $rabbit_host                  = 'localhost',
  $rabbit_hosts                 = undef,
  $rabbit_password              = 'guest',
  $rabbit_port                  = '5672',
  $rabbit_userid                = 'guest',
  $rabbit_virtual_host          = '/',
  $rabbit_use_ssl               = false,
  $rabbit_ha_queues             = undef,
  $rabbit_notification_topic    = 'notifications',
  $kombu_ssl_ca_certs           = undef,
  $kombu_ssl_certfile           = undef,
  $kombu_ssl_keyfile            = undef,
  $kombu_ssl_version            = 'TLSv1',
  $kombu_reconnect_delay        = $::os_service_default,
  $amqp_durable_queues          = false,
  $database_connection          = undef,
  $database_idle_timeout        = undef,
  $database_max_retries         = undef,
  $database_retry_interval      = undef,
  $database_min_pool_size       = undef,
  $database_max_pool_size       = undef,
  $database_max_overflow        = undef,
  $rpc_backend                  = 'rabbit',
  $nova_compute_url             = false,
  $nova_proxy_admin_user        = 'admin',
  $nova_proxy_admin_tenant_name = 'admin',
  $control_exchange             = 'trove',
  $cinder_url                   = false,
  $swift_url                    = false,
  $neutron_url                  = false,
  $os_region_name               = undef,
  $nova_compute_service_type    = 'compute',
  $cinder_service_type          = 'volumev2',
  $swift_service_type           = 'object-store',
  $heat_service_type            = 'orchestration',
  $neutron_service_type         = 'network',
  $use_neutron                  = true,
  $package_ensure               = 'present',
  # DEPRECATED PARAMETERS
  $qpid_hostname                = undef,
  $qpid_port                    = undef,
  $qpid_username                = undef,
  $qpid_password                = undef,
  $qpid_sasl_mechanisms         = undef,
  $qpid_heartbeat               = undef,
  $qpid_protocol                = undef,
  $qpid_tcp_nodelay             = undef,
) {
  include ::trove::deps
  include ::trove::params

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
}
