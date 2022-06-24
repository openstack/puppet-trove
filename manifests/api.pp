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
# [*package_ensure*]
#   (optional) Whether the trove api package will be installed
#   Defaults to 'present'
#
# [*bind_host*]
#   (optional) The address of the host to bind to.
#   Default: $::os_service_default
#
# [*bind_port*]
#   (optional) The port the server should bind to.
#   Default: $::os_service_default
#
# [*backlog*]
#   (optional) Backlog requests when creating socket
#   Default: $::os_service_default
#
# [*workers*]
#   (optional) Number of trove API worker processes to start
#   Default: $::os_workers
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
#   Defaults to $::os_service_default.
#
# [*http_post_rate*]
#   (optional) Default rate limit of POST request.
#   Defaults to $::os_service_default.
#
# [*http_put_rate*]
#   (optional) Default rate limit of PUT request.
#   Defaults to $::os_service_default.
#
# [*http_delete_rate*]
#   (optional) Default rate limit of DELETE request.
#   Defaults to $::os_service_default.
#
# [*http_mgmt_post_rate*]
#   (optional) Default rate limit of mgmt post request.
#   Defaults to $::os_service_default.
#
# [*auth_strategy*]
#   (optional) The strategy to use for authentication.
#   Defaults to 'keystone'
#
# [*taskmanager_queue*]
#   (optional) Message queue name the Taskmanager will listen to.
#   Defaults to $::os_service_default.
#
class trove::api(
  $bind_host           = $::os_service_default,
  $bind_port           = $::os_service_default,
  $backlog             = $::os_service_default,
  $workers             = $::os_workers,
  $enabled             = true,
  $purge_config        = false,
  $cert_file           = false,
  $key_file            = false,
  $ca_file             = false,
  $http_get_rate       = $::os_service_default,
  $http_post_rate      = $::os_service_default,
  $http_put_rate       = $::os_service_default,
  $http_delete_rate    = $::os_service_default,
  $http_mgmt_post_rate = $::os_service_default,
  $manage_service      = true,
  $package_ensure      = 'present',
  $auth_strategy       = 'keystone',
  $taskmanager_queue   = $::os_service_default,
) {

  include trove::deps
  include trove::db
  include trove::db::sync
  include trove::params
  include trove::api::service_credentials

  # basic service config
  trove_config {
    'DEFAULT/bind_host':         value => $bind_host;
    'DEFAULT/bind_port':         value => $bind_port;
    'DEFAULT/backlog':           value => $backlog;
    'DEFAULT/trove_api_workers': value => $workers;
  }

  if $auth_strategy == 'keystone' {
    include trove::keystone::authtoken
  }

  # SSL Options
  if $cert_file {
    trove_config {
      'ssl/cert_file': value => $cert_file;
    }
  } else {
    trove_config {
      'ssl/cert_file': ensure => absent;
    }
  }
  if $key_file {
    trove_config {
      'ssl/key_file': value => $key_file;
    }
  } else {
    trove_config {
      'ssl/key_file': ensure => absent;
    }
  }
  if $ca_file {
    trove_config {
      'ssl/ca_file': value => $ca_file;
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

  trove_config {
    'DEFAULT/taskmanager_queue': value => $taskmanager_queue;
  }

  trove::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_ensure => $package_ensure,
    package_name   => $::trove::params::api_package_name,
    service_name   => $::trove::params::api_service_name,
  }
}
