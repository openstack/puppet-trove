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
# trove::db::mysql
#
# Manages the trove MySQL database
#
# === Parameters:
#
# [*password*]
#   (required) Password that will be used for the trove db user.
#
# [*dbname*]
#   (optionnal) Name of trove database.
#   Defaults to trove
#
# [*user*]
#   (optionnal) Name of trove user.
#   Defaults to trove
#
# [*host*]
#   (optionnal) Host where user should be allowed all priveleges for database.
#   Defaults to 127.0.0.1
#
# [*charset*]
#   (optionnal) Charset of trove database
#   Defaults 'utf8'
#
# [*collate*]
#   (optionnal) Charset collate of trove database
#   Defaults 'utf8_unicode_ci'
#
# [*allowed_hosts*]
#   Hosts allowed to use the database
#
# [*mysql_module*]
#   (optional) The mysql puppet module version to use
#   Tested versions include 0.9 and 2.2
#   Default to '0.9'
#
# == Dependencies
#   Class['mysql::server']
#
class trove::db::mysql(
  $password,
  $dbname        = 'trove',
  $user          = 'trove',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_unicode_ci',
  $mysql_module  = '0.9',
  $allowed_hosts = undef
) {

  Class['trove::db::mysql'] -> Exec<| title == 'trove-db-sync' |>
  Mysql::Db[$dbname] -> Anchor<| title == 'trove-start' |>
  Mysql::Db[$dbname] ~> Exec<| title == 'trove-db-sync' |>

  if ($mysql_module >= 2.2) {
    mysql::db { $dbname:
      user     => $user,
      password => $password,
      host     => $host,
      charset  => $charset,
      collate  => $collate,
      require  => Service['mysqld'],
    }
  } else {
    require mysql::python

    mysql::db { $dbname:
      user     => $user,
      password => $password,
      host     => $host,
      charset  => $charset,
      require  => Class['mysql::config'],
    }
  }

  # Check allowed_hosts to avoid duplicate resource declarations
  if is_array($allowed_hosts) and delete($allowed_hosts,$host) != [] {
    $real_allowed_hosts = delete($allowed_hosts,$host)
  } elsif is_string($allowed_hosts) and ($allowed_hosts != $host) {
    $real_allowed_hosts = $allowed_hosts
  }

  if $real_allowed_hosts {
    trove::db::mysql::host_access { $real_allowed_hosts:
      user          => $user,
      password      => $password,
      database      => $dbname,
      mysql_module  => $mysql_module,
    }

    Trove::Db::Mysql::Host_access[$real_allowed_hosts] -> Exec<| title == 'trove-db-sync' |>

  }

}
