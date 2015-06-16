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
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*port*]
#   (optional) DEPRECATED: Use public_url, internal_url and admin_url instead.
#   Default port for endpoints. (Defaults to 9001)
#   Setting this parameter overrides public_url, internal_url and admin_url parameters.
#
# [*public_port*]
#   (optional) DEPRECATED: Use public_url instead.
#   Default port for endpoints. (Defaults to $port)
#   Setting this parameter overrides public_url parameter.
#
# [*public_protocol*]
#   (optional) DEPRECATED: Use public_url instead.
#   Protocol for public endpoint. (Defaults to 'http')
#   Setting this parameter overrides public_url parameter.
#
# [*public_address*]
#   (optional) DEPRECATED: Use public_url instead.
#   Public address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides public_url parameter.
#
# [*internal_protocol*]
#   (optional) DEPRECATED: Use internal_url instead.
#   Protocol for internal endpoint. (Defaults to 'http')
#   Setting this parameter overrides internal_url parameter.
#
# [*internal_address*]
#   (optional) DEPRECATED: Use internal_url instead.
#   Internal address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides internal_url parameter.
#
# [*admin_protocol*]
#   (optional) DEPRECATED: Use admin_url instead.
#   Protocol for admin endpoint. (Defaults to 'http')
#   Setting this parameter overrides admin_url parameter.
#
# [*admin_address*]
#   (optional) DEPRECATED: Use admin_url instead.
#   Admin address for endpoint. (Defaults to '127.0.0.1')
#   Setting this parameter overrides admin_url parameter.
#
# === Deprecation notes
#
# If any value is provided for public_protocol, public_address or port parameters,
# public_url will be completely ignored. The same applies for internal and admin parameters.
#
# === Examples
#
#  class { 'trove::keystone::auth':
#    public_url   => 'https://10.0.0.10:8779/v1.0/%(tenant_id)s',
#    internal_url => 'https://10.0.0.11:8779/v1.0/%(tenant_id)s',
#    admin_url    => 'https://10.0.0.11:8779/v1.0/%(tenant_id)s',
#  }
#
class trove::keystone::auth (
  $password,
  $auth_name          = 'trove',
  $email              = 'trove@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_name       = undef,
  $service_type       = 'database',
  $region             = 'RegionOne',
  $public_url         = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  $admin_url          = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  $internal_url       = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  # DEPRECATED PARAMETERS
  $port               = undef,
  $public_port        = undef,
  $public_protocol    = undef,
  $public_address     = undef,
  $internal_protocol  = undef,
  $internal_address   = undef,
  $admin_protocol     = undef,
  $admin_address      = undef,
) {

  if $port {
    warning('The port parameter is deprecated, use public_url, internal_url and admin_url instead.')
  }

  if $public_port {
    warning('The public_port parameter is deprecated, use public_url instead.')
  }

  if $public_protocol {
    warning('The public_protocol parameter is deprecated, use public_url instead.')
  }

  if $internal_protocol {
    warning('The internal_protocol parameter is deprecated, use internal_url instead.')
  }

  if $admin_protocol {
    warning('The admin_protocol parameter is deprecated, use admin_url instead.')
  }

  if $public_address {
    warning('The public_address parameter is deprecated, use public_url instead.')
  }

  if $internal_address {
    warning('The internal_address parameter is deprecated, use internal_url instead.')
  }

  if $admin_address {
    warning('The admin_address parameter is deprecated, use admin_url instead.')
  }

  if ($public_protocol or $public_address or $port or $public_port) {
    $public_url_real = sprintf('%s://%s:%s/v1.0/%%(tenant_id)s',
      pick($public_protocol, 'http'),
      pick($public_address, '127.0.0.1'),
      pick($public_port, $port, '8779'))
  } else {
    $public_url_real = $public_url
  }

  if ($admin_protocol or $admin_address or $port) {
    $admin_url_real = sprintf('%s://%s:%s/v1.0/%%(tenant_id)s',
      pick($admin_protocol, 'http'),
      pick($admin_address, '127.0.0.1'),
      pick($port, '8779'))
  } else {
    $admin_url_real = $admin_url
  }

  if ($internal_protocol or $internal_address or $port) {
    $internal_url_real = sprintf('%s://%s:%s/v1.0/%%(tenant_id)s',
      pick($internal_protocol, 'http'),
      pick($internal_address, '127.0.0.1'),
      pick($port, '8779'))
  } else {
    $internal_url_real = $internal_url
  }

  $real_service_name = pick($service_name, $auth_name)

  Keystone_user_role["${auth_name}@${tenant}"]        ~> Service <| name == 'trove-server' |>
  Keystone_endpoint["${region}/${real_service_name}"] ~> Service <| name == 'trove-server' |>

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
    public_url          => $public_url_real,
    internal_url        => $internal_url_real,
    admin_url           => $admin_url_real,
  }

}
