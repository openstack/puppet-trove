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
# == Class: trove::taskmanager
#
# Manages trove taskmanager package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove-taskmanager service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ensure_package*]
#   (optional) The state of the trove taskmanager package
#   Defaults to 'present'
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: false
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $::os_service_default, it will not log to any file.
#   Default: /var/log/trove/trove-taskmanager.log
#
# [*log_dir*]
#   (optional) directory to which trove logs are sent.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/trove'
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to $::os_service_default
#
# [*guest_log_file*]
#   (optional) The path of file used for logging.
#   If set to $::os_service_default, it will not log to any file.
#   Defaults to '/var/log/trove/trove-guestagent.log'
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to 'http://localhost:5000/v2.0'.
#
# [*heat_url*]
#   (optional) URL without the tenant segment.
#   Defaults to false
#
# [*guestagent_config_file*]
#   (optional) Trove guest agent configuration file.
#   Defaults to '/etc/trove/trove-guestagent.conf'.
#
# [*default_neutron_networks*]
#   (optional) The network that trove will attach by default.
#   Defaults to undef.
#
# [*taskmanager_queue*]
#   (optional) Message queue name the Taskmanager will listen to.
#   Defaults to 'taskmanager'.
#
# DEPRECATED OPTIONS
#
# [*use_guestagent_template*]
#   (optional) Use template to provision trove guest agent configuration file.
#   Defaults to true.
#
# [*verbose*]
#   (optional) Deprecated. Rather to log the trove api service at verbose level.
#   Default: undef
#
class trove::taskmanager(
  $enabled                  = true,
  $manage_service           = true,
  $debug                    = $::os_service_default,
  $log_file                 = '/var/log/trove/trove-taskmanager.log',
  $log_dir                  = '/var/log/trove',
  $use_syslog               = $::os_service_default,
  $guest_log_file           = '/var/log/trove/trove-guestagent.log',
  $log_facility             = $::os_service_default,
  $auth_url                 = 'http://localhost:5000/v2.0',
  $heat_url                 = false,
  $ensure_package           = 'present',
  $guestagent_config_file   = '/etc/trove/trove-guestagent.conf',
  $default_neutron_networks = undef,
  $taskmanager_queue        = 'taskmanager',
  #DEPRECATED OPTIONS
  $use_guestagent_template  = true,
  $verbose                  = undef,
) inherits trove {

  include ::trove::deps
  include ::trove::params

  if $verbose {
    warning('verbose is deprecated, has no effect and will be removed after Newton cycle.')
  }

  if $::trove::database_connection {
    if($::trove::database_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require '::mysql::bindings'
      require '::mysql::bindings::python'
    } elsif($::trove::database_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($::trove::database_connection =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${::trove::database_connection}")
    }
    trove_taskmanager_config {
      'database/connection':   value => $::trove::database_connection;
      'database/idle_timeout': value => $::trove::database_idle_timeoutl;
    }
  }

  # basic service config
  trove_taskmanager_config {
    'DEFAULT/trove_auth_url':               value => $auth_url;
    'DEFAULT/nova_proxy_admin_user':        value => $::trove::nova_proxy_admin_user;
    'DEFAULT/nova_proxy_admin_pass':        value => $::trove::nova_proxy_admin_pass;
    'DEFAULT/nova_proxy_admin_tenant_name': value => $::trove::nova_proxy_admin_tenant_name;
  }

  trove_config {
    'DEFAULT/taskmanager_queue':   value => $taskmanager_queue;
  }

  # region name
  if $::trove::os_region_name {
    trove_taskmanager_config { 'DEFAULT/os_region_name': value => $::trove::os_region_name }
  }
  else {
    trove_taskmanager_config {'DEFAULT/os_region_name': ensure => absent }
  }

  # services type
  trove_taskmanager_config {
    'DEFAULT/nova_compute_service_type': value => $::trove::nova_compute_service_type;
    'DEFAULT/cinder_service_type':       value => $::trove::cinder_service_type;
    'DEFAULT/neutron_service_type':      value => $::trove::neutron_service_type;
    'DEFAULT/swift_service_type':        value => $::trove::swift_service_type;
    'DEFAULT/heat_service_type':         value => $::trove::heat_service_type;
  }

  oslo::messaging::default { 'trove_taskmanager_config':
    transport_url    => $::trove::default_transport_url,
    control_exchange => $::trove::control_exchange
  }

  oslo::messaging::notifications { 'trove_taskmanager_config':
    transport_url => $::trove::notification_transport_url,
    driver        => $::trove::notification_driver,
    topics        => $::trove::notification_topics
  }

  if $::trove::rpc_backend == 'trove.openstack.common.rpc.impl_kombu' or $::trove::rpc_backend == 'rabbit' {
    oslo::messaging::rabbit { 'trove_taskmanager_config':
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
    oslo::messaging::amqp { 'trove_taskmanager_config':
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
    trove_taskmanager_config {
      'DEFAULT/rpc_backend' : value => $::trove::rpc_backend
    }
  }

  if $::trove::use_neutron {
    trove_config {
      'DEFAULT/network_label_regex':         value => '.*';
      'DEFAULT/network_driver':              value => 'trove.network.neutron.NeutronDriver';
      'DEFAULT/default_neutron_networks':    value => $default_neutron_networks;
    }

    trove_taskmanager_config {
      'DEFAULT/network_label_regex':         value => '.*';
      'DEFAULT/network_driver':              value => 'trove.network.neutron.NeutronDriver';
      'DEFAULT/default_neutron_networks':    value => $default_neutron_networks;
    }
  } else {
    trove_config {
      'DEFAULT/network_label_regex':         value => '^private$';
      'DEFAULT/network_driver':              value => 'trove.network.nova.NovaNetwork';
      'DEFAULT/default_neutron_networks':    ensure => absent;
    }

    trove_taskmanager_config {
      'DEFAULT/network_label_regex':         value => '^private$';
      'DEFAULT/network_driver':              value => 'trove.network.nova.NovaNetwork';
      'DEFAULT/default_neutron_networks':    ensure => absent;
    }
  }

  oslo::log { 'trove_taskmanager_config':
    debug               => $debug,
    log_file            => $log_file,
    log_dir             => $log_dir,
    use_syslog          => $use_syslog,
    syslog_log_facility => $log_facility
  }

  trove::generic_service { 'taskmanager':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::taskmanager_package_name,
    service_name   => $::trove::params::taskmanager_service_name,
    ensure_package => $ensure_package,
  }

  if $guestagent_config_file {
    if $use_guestagent_template {
      warning("The tempated guestagent file is deprecated and will be removed in Ocata. \
Please configure options directly with the trove::guestagent class using hiera.")
      file { $guestagent_config_file:
        content => template('trove/trove-guestagent.conf.erb'),
        require => Anchor['trove::install::end'],
      }
    } else {
      class {'::trove::guestagent':
        enabled        => false,
        manage_service => false,
      }
    }

    trove_taskmanager_config {
      'DEFAULT/guest_config': value => $guestagent_config_file
    }
  }

  # TO-DO(mmagr): Disabling transformer workarounds bug #1402055.
  #               Remove this hack as soon as bug is fixed.
  trove_taskmanager_config {
    'DEFAULT/exists_notification_transformer': ensure => absent,
  }
}
