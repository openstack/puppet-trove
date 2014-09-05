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
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#   Defaults to 'localhost'
#
# [*rabbit_hosts*]
#   (optional) List of clustered rabbit servers.
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
#   Defaults to 'SSLv3'
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to false
#
# [*qpid_hostname*]
#   (optional) Location of qpid server
#   Defaults to 'localhost'
#
# [*qpid_port*]
#   (optional) Port for qpid server
#   Defaults to '5672'
#
# [*qpid_username*]
#   (optional) Username to use when connecting to qpid
#   Defaults to 'guest'
#
# [*qpid_password*]
#   (optional) Password to use when connecting to qpid
#   Defaults to 'guest'
#
# [*qpid_heartbeat*]
#   (optional) Seconds between connection keepalive heartbeats
#   Defaults to 60
#
# [*qpid_protocol*]
#   (optional) Transport to use, either 'tcp' or 'ssl''
#   Defaults to 'tcp'
#
# [*qpid_sasl_mechanisms*]
#   (optional) Enable one or more SASL mechanisms
#   Defaults to false
#
# [*qpid_tcp_nodelay*]
#   (optional) Disable Nagle algorithm
#   Defaults to true
#
# [*rpc_backend*]
#   (optional) The rpc backend implementation to use, can be:
#     trove.openstack.common.rpc.impl_kombu (for rabbitmq)
#     trove.openstack.common.rpc.impl_qpid  (for qpid)
#   Defaults to 'trove.openstack.common.rpc.impl_kombu'
#
# [*mysql_module*]
#   (optional) Deprecated. Does nothing.
#   Defaults to undef.
#
# [*database_connection*]
#   (optional) Connection url to connect to trove database.
#   Defaults to 'sqlite:////var/lib/trove/trove.sqlite'
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to 3600
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
class trove(
  $nova_proxy_admin_pass,
  $rabbit_host                  = 'localhost',
  $rabbit_hosts                 = false,
  $rabbit_password              = 'guest',
  $rabbit_port                  = '5672',
  $rabbit_userid                = 'guest',
  $rabbit_virtual_host          = '/',
  $rabbit_use_ssl               = false,
  $rabbit_notification_topic    = 'notifications',
  $kombu_ssl_ca_certs           = undef,
  $kombu_ssl_certfile           = undef,
  $kombu_ssl_keyfile            = undef,
  $kombu_ssl_version            = 'SSLv3',
  $amqp_durable_queues          = false,
  $database_connection          = 'sqlite:////var/lib/trove/trove.sqlite',
  $database_idle_timeout        = 3600,
  $rpc_backend                  = 'trove.openstack.common.rpc.impl_kombu',
  $nova_compute_url             = false,
  $nova_proxy_admin_user        = 'admin',
  $nova_proxy_admin_tenant_name = 'admin',
  $control_exchange             = 'trove',
  $cinder_url                   = false,
  $swift_url                    = false,
  # DEPRECATED PARAMETERS
  $mysql_module                 = undef,
) {
  include trove::params

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  exec { 'post-trove_config':
    command     => '/bin/echo "Trove config has changed"',
    refreshonly => true,
  }

  Trove_datastore<||> -> Trove_datastore_version<||>

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
}
