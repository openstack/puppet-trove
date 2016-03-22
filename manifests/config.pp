#
# Copyright (C) 2015  UnitedStack <devops@unitedstack.com>
#
# Author: Xingchao Yu <xingchao@unitedstack.com>
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
# == Class: trove::config
#
# This class is used to manage arbitrary trove configurations.
#
# === Parameters
#
# [*trove_config*]
#   (optional) Allow configuration of arbitrary trove configurations.
#   The value is an hash of trove_config resources.
#   Defaults to {}
#
# [*trove_taskmanager_config*]
#   (optional) Allow configuration of arbitrary trove taskmanager configurations.
#   The value is an hash of trove_taskmanager_config resources.
#   Defaults to {}
#
# [*trove_conductor_config*]
#   (optional) Allow configuration of arbitrary trove conductor configurations.
#   The value is an hash of trove_conductor_config resources.
#   Defaults to {}
#
# [*trove_guestagent_config*]
#   (optional) Allow configuration of arbitrary trove guestagent configurations.
#   The value is an hash of trove_guestagent_config resources.
#   Defaults to {}
#
# [*trove_api_paste_ini*]
#   (optional) Allow configuration of arbitrary trove paste api configurations.
#   The value is an hash of trove_paste_api_ini resources.
#   Defaults to {}
#
#   Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#
#   In yaml format, Example:
#   trove_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class trove::config (
  $trove_config             = {},
  $trove_taskmanager_config = {},
  $trove_conductor_config   = {},
  $trove_guestagent_config  = {},
  $trove_api_paste_ini      = {},
) {

  include ::trove::deps

  validate_hash($trove_config)
  validate_hash($trove_taskmanager_config)
  validate_hash($trove_conductor_config)
  validate_hash($trove_guestagent_config)
  validate_hash($trove_api_paste_ini)

  create_resources('trove_config', $trove_config)
  create_resources('trove_taskmanager_config', $trove_taskmanager_config)
  create_resources('trove_conductor_config', $trove_conductor_config)
  create_resources('trove_guestagent_config', $trove_guestagent_config)
  create_resources('trove_api_paste_ini', $trove_api_paste_ini)

}
