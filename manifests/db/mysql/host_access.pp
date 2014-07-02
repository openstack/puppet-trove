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
define trove::db::mysql::host_access(
  $user,
  $password,
  $database,
  $mysql_module = '0.9'
) {
  if ($mysql_module >= 2.2) {
    mysql_user { "${user}@${name}":
      password_hash => mysql_password($password),
      require       => Mysql_database[$database],
    }
    mysql_grant { "${user}@${name}/${database}.*":
      privileges => ['ALL'],
      options    => ['GRANT'],
      table      => "${database}.*",
      require    => Mysql_user["${user}@${name}"],
      user       => "${user}@${name}"
    }
  } else {
    database_user { "${user}@${name}":
      password_hash => mysql_password($password),
      provider      => 'mysql',
      require       => Database[$database],
    }
    database_grant { "${user}@${name}/${database}":
      privileges => 'all',
      provider   => 'mysql',
      require    => Database_user["${user}@${name}"]
    }
  }
}
