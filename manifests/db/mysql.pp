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
# == Class: trove::db::mysql
#
# The trove::db::mysql class creates a MySQL database for trove.
# It must be used on the MySQL server
#
# === Parameters
#
# [*password*]
#   (required) Password that will be used for the trove db user.
#
# [*dbname*]
#   (optional) Name of trove database.
#   Defaults to trove
#
# [*user*]
#   (optional) Name of trove user.
#   Defaults to trove
#
# [*host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to undef.
#
# [*charset*]
#   (optional) Charset of trove database
#   Defaults 'utf8'.
#
# [*collate*]
#   (optional) Charset collate of trove database
#   Defaults 'utf8_general_ci'.
#
class trove::db::mysql(
  $password,
  $dbname        = 'trove',
  $user          = 'trove',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
) {

  include ::trove::deps

  validate_string($password)

  ::openstacklib::db::mysql { 'trove':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  Anchor['trove::db::begin']
  ~> Class['trove::db::mysql']
  ~> Anchor['trove::db::end']
}
