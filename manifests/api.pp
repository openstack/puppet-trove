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
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of trove-api.
#   If the value is 'httpd', this means trove-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'trove::wsgi::apache'...}
#   to make trove-api be a web app using apache mod_wsgi.
#   Defaults to '$trove::params::api_service'
#
# [*package_ensure*]
#   (optional) Whether the trove api package will be installed
#   Defaults to 'present'
#
# [*bind_host*]
#   (optional) The address of the host to bind to.
#   Default: $facts['os_service_default']
#
# [*bind_port*]
#   (optional) The port the server should bind to.
#   Default: $facts['os_service_default']
#
# [*backlog*]
#   (optional) Backlog requests when creating socket
#   Default: $facts['os_service_default']
#
# [*workers*]
#   (optional) Number of trove API worker processes to start
#   Default: $facts['os_workers']
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
# [*sync_db*]
#   (optional) Enable dbsync.
#   Defaults to true.
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
#   Defaults to $facts['os_service_default'].
#
# [*http_post_rate*]
#   (optional) Default rate limit of POST request.
#   Defaults to $facts['os_service_default'].
#
# [*http_put_rate*]
#   (optional) Default rate limit of PUT request.
#   Defaults to $facts['os_service_default'].
#
# [*http_delete_rate*]
#   (optional) Default rate limit of DELETE request.
#   Defaults to $facts['os_service_default'].
#
# [*http_mgmt_post_rate*]
#   (optional) Default rate limit of mgmt post request.
#   Defaults to $facts['os_service_default'].
#
# [*auth_strategy*]
#   (optional) The strategy to use for authentication.
#   Defaults to 'keystone'
#
# [*taskmanager_queue*]
#   (optional) Message queue name the Taskmanager will listen to.
#   Defaults to $facts['os_service_default'].
#
class trove::api (
  Boolean $manage_service = true,
  $service_name           = $trove::params::api_service_name,
  $package_ensure         = 'present',
  $bind_host              = $facts['os_service_default'],
  $bind_port              = $facts['os_service_default'],
  $backlog                = $facts['os_service_default'],
  $workers                = $facts['os_workers'],
  Boolean $enabled        = true,
  Boolean $purge_config   = false,
  Boolean $sync_db        = true,
  $cert_file              = $facts['os_service_default'],
  $key_file               = $facts['os_service_default'],
  $ca_file                = $facts['os_service_default'],
  $http_get_rate          = $facts['os_service_default'],
  $http_post_rate         = $facts['os_service_default'],
  $http_put_rate          = $facts['os_service_default'],
  $http_delete_rate       = $facts['os_service_default'],
  $http_mgmt_post_rate    = $facts['os_service_default'],
  $auth_strategy          = 'keystone',
  $taskmanager_queue      = $facts['os_service_default'],
) inherits trove::params {
  include trove::deps
  include trove::db
  include trove::policy

  if $sync_db {
    include trove::db::sync
  }

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

  oslo::service::ssl { 'trove_config':
    cert_file => $cert_file,
    key_file  => $key_file,
    ca_file   => $ca_file,
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

  if $service_name == $trove::params::api_service_name {
    trove::generic_service { 'api':
      enabled        => $enabled,
      manage_service => $manage_service,
      package_ensure => $package_ensure,
      package_name   => $trove::params::api_package_name,
      service_name   => $service_name,
    }
    if $manage_service {
      Trove_api_paste_ini<||> ~> Service['trove-api']
    }
  } elsif $service_name == 'httpd' {
    trove::generic_service { 'api':
      enabled        => false,
      manage_service => $manage_service,
      package_ensure => $package_ensure,
      package_name   => $trove::params::api_package_name,
      service_name   => $trove::params::api_service_name,
    }
    if $manage_service {
      Service<| title == 'httpd' |> { tag +> 'trove-service' }
      Service['trove-api'] -> Service[$service_name]
      Trove_api_paste_ini<||> ~> Service['httpd']
    }
  } else {
    fail("Invalid service_name. Either trove-api/openstack-trove-api for \
running as a standalone service, or httpd for being run by a httpd server")
  }
}
