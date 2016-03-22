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

# trove::client
#
# Manages the trove client package on systems
#
# === Parameters:
#
# [*client_package_name*]
#   (optional) The name of python trove client package
#   Defaults to $trove::params::client_package_name
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
#
class trove::client (
  $client_package_name = $trove::params::client_package_name,
  $package_ensure = present,
) inherits trove::params {

  include ::trove::deps

  package { 'python-troveclient':
    ensure => $package_ensure,
    name   => $client_package_name,
    tag    => 'openstack',
  }

}
