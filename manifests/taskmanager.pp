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
# [*package_ensure*]
#   (optional) The state of the trove taskmanager package
#   Defaults to 'present'
#
# [*guest_log_file*]
#   (optional) The path of file used for logging.
#   If set to $facts['os_service_default'], it will not log to any file.
#   Defaults to '/var/log/trove/trove-guestagent.log'
#
# [*guestagent_config_file*]
#   (optional) Trove guest agent configuration file.
#   Defaults to '/etc/trove/trove-guestagent.conf'.
#
# [*taskmanager_manager*]
#   Trove taskmanager entry point.
#   Defaults to 'trove.taskmanager.manager.Manager'.
#
class trove::taskmanager(
  Boolean $enabled          = true,
  Boolean $manage_service   = true,
  $guest_log_file           = '/var/log/trove/trove-guestagent.log',
  $package_ensure           = 'present',
  $guestagent_config_file   = '/etc/trove/trove-guestagent.conf',
  $taskmanager_manager      = 'trove.taskmanager.manager.Manager',
) inherits trove {

  include trove::deps
  include trove::params

  # basic service config
  trove_config {
    'DEFAULT/guest_config':        value => $guestagent_config_file;
    'DEFAULT/taskmanager_manager': value => $taskmanager_manager;
  }
  include trove::guestagent

  trove::generic_service { 'taskmanager':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::taskmanager_package_name,
    service_name   => $::trove::params::taskmanager_service_name,
    package_ensure => $package_ensure,
  }

  # TO-DO(mmagr): Disabling transformer workarounds bug #1402055.
  #               Remove this hack as soon as bug is fixed.
  trove_config {
    'DEFAULT/exists_notification_transformer': ensure => absent,
  }
}
