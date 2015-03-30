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
# trove::keystone::auth
#
# Configures Trove user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for Trove user.
#
# [*auth_name*]
#   Username for Trove service. Defaults to 'trove'.
#
# [*email*]
#   Email for Trove user. Defaults to 'trove@localhost'.
#
# [*tenant*]
#   Tenant for Trove user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should Trove endpoint be configured? Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'database'.
#
# [*public_protocol*]
#   Protocol for public endpoint. Defaults to 'http'.
#
# [*public_address*]
#   Public address for endpoint. Defaults to '127.0.0.1'.
#
# [*admin_protocol*]
#   Protocol for admin endpoint. Defaults to 'http'.
#
# [*admin_address*]
#   Admin address for endpoint. Defaults to '127.0.0.1'.
#
# [*internal_protocol*]
#   Protocol for internal endpoint. Defaults to 'http'.
#
# [*internal_address*]
#   Internal address for endpoint. Defaults to '127.0.0.1'.
#
# [*port*]
#   Port for endpoint. Defaults to '8779'.
#
# [*public_port*]
#   Port for public endpoint. Defaults to $port.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
#
class trove::keystone::auth (
  $password,
  $auth_name          = 'trove',
  $email              = 'trove@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_name       = undef,
  $service_type       = 'database',
  $public_protocol    = 'http',
  $public_address     = '127.0.0.1',
  $admin_protocol     = 'http',
  $admin_address      = '127.0.0.1',
  $internal_protocol  = 'http',
  $internal_address   = '127.0.0.1',
  $port               = '8779',
  $public_port        = undef,
  $region             = 'RegionOne'
) {

  $real_service_name    = pick($service_name, $auth_name)

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'trove-server' |>
  Keystone_endpoint["${region}/${real_service_name}"]  ~> Service <| name == 'trove-server' |>

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }

  keystone::resource::service_identity { 'trove':
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => $configure_endpoint,
    service_name        => $real_service_name,
    service_type        => $service_type,
    service_description => 'Trove Database Service',
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => "${public_protocol}://${public_address}:${real_public_port}/v1.0/\$(tenant_id)s",
    internal_url        => "${internal_protocol}://${internal_address}:${port}/v1.0/\$(tenant_id)s",
    admin_url           => "${admin_protocol}://${admin_address}:${port}/v1.0/\$(tenant_id)s",
  }

}
