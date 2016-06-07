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
# [*configure_user*]
#   Should Trove user be configured?
#   Defaults to 'true'.
#
# [*configure_user_role*]
#   Should Trove user_role be configured?
#   Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'database'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to 'trove'.
#
# [*service_description*]
#   (optional) Description for keystone service.
#   Defaults to 'Trove Database Service'.
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
  $auth_name           = 'trove',
  $email               = 'trove@localhost',
  $tenant              = 'services',
  $configure_user      = true,
  $configure_user_role = true,
  $configure_endpoint  = true,
  $service_name        = 'trove',
  $service_type        = 'database',
  $service_description = 'Trove Database Service',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  $admin_url           = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  $internal_url        = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
) {

  include ::trove::deps

  Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| tag == 'trove-server' |>

  Keystone_endpoint<| title == "${region}/${service_name}::${service_type}" |>
  ~> Service <| tag == 'trove-server' |>

  keystone::resource::service_identity { 'trove':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
