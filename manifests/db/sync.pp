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
# Class to execute "trove-manage db_sync
#
# [*db_sync_timeout*]
#   (Optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
class trove::db::sync (
  $db_sync_timeout = 300,
) {
  include trove::deps
  include trove::params

  exec { 'trove-manage db_sync':
    path        => '/usr/bin',
    user        => $trove::params::user,
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['trove::install::end'],
      Anchor['trove::config::end'],
      Anchor['trove::dbsync::begin']
    ],
    notify      => Anchor['trove::dbsync::end'],
    tag         => 'openstack-db',
  }
}
