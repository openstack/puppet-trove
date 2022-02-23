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
#   If set to $::os_service_default, it will not log to any file.
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
# DEPRECATED OPTIONS
#
# [*use_guestagent_template*]
#   (optional) Use template to provision trove guest agent configuration file.
#   Defaults to true.
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to undef
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: undef
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $::os_service_default, it will not log to any file.
#   Default: undef
#
# [*log_dir*]
#   (optional) directory to which trove logs are sent.
#   If set to $::os_service_default, it will not log to any directory.
#   Defaults to undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef
#
class trove::taskmanager(
  $enabled                  = true,
  $manage_service           = true,
  $guest_log_file           = '/var/log/trove/trove-guestagent.log',
  $package_ensure           = 'present',
  $guestagent_config_file   = '/etc/trove/trove-guestagent.conf',
  $taskmanager_manager      = 'trove.taskmanager.manager.Manager',
  #DEPRECATED OPTIONS
  $use_guestagent_template  = true,
  $auth_url                 = undef,
  $debug                    = undef,
  $log_file                 = undef,
  $log_dir                  = undef,
  $use_syslog               = undef,
  $log_facility             = undef,
) inherits trove {

  include trove::deps
  include trove::params

  # Remove individual config files so that we do not leave any parameters
  # configured by older version
  file { '/etc/trove/trove-taskmanager.conf':
    ensure  => absent,
    require => Anchor['trove::config::begin'],
    notify  => Anchor['trove::config::end']
  }

  # basic service config
  trove_config {
    'DEFAULT/taskmanager_manager': value => $taskmanager_manager;
  }

  trove::generic_service { 'taskmanager':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::taskmanager_package_name,
    service_name   => $::trove::params::taskmanager_service_name,
    package_ensure => $package_ensure,
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
      class {'trove::guestagent':
        enabled        => false,
        manage_service => false,
      }
    }

    trove_config {
      'DEFAULT/guest_config': value => $guestagent_config_file
    }
  }

  # TO-DO(mmagr): Disabling transformer workarounds bug #1402055.
  #               Remove this hack as soon as bug is fixed.
  trove_config {
    'DEFAULT/exists_notification_transformer': ensure => absent,
  }
}
