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
#   (Required) Password for Trove user.
#
# [*auth_name*]
#   (Optional) Username for Trove service.
#   Defaults to 'trove'.
#
# [*email*]
#   (Optional) Email for Trove user.
#   Defaults to 'trove@localhost'.
#
# [*tenant*]
#   (Optional) Tenant for Trove user.
#   Defaults to 'services'.
#
# [*roles*]
#   (Optional) List of roles assigned to trove user.
#   Defaults to ['admin']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to trove user.
#   Defaults to []
#
# [*configure_endpoint*]
#   (Optional) Should Trove endpoint be configured?
#   Defaults to true.
#
# [*configure_user*]
#   (Optional) Should Trove user be configured?
#   Defaults to true.
#
# [*configure_user_role*]
#   (Optional) Should Trove user_role be configured?
#   Defaults to true.
#
# [*configure_service*]
#   (Optional) Should the service be configurd?
#   Defaults to True
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'database'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'trove'.
#
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'Trove Database Service'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*public_url*]
#   (0ptional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s'
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s'
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8779/v1.0/%(tenant_id)s'
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
  String[1] $password,
  String[1] $auth_name                    = 'trove',
  String[1] $email                        = 'trove@localhost',
  String[1] $tenant                       = 'services',
  Array[String[1]] $roles                 = ['admin'],
  String[1] $system_scope                 = 'all',
  Array[String[1]] $system_roles          = [],
  Boolean $configure_user                 = true,
  Boolean $configure_user_role            = true,
  Boolean $configure_endpoint             = true,
  Boolean $configure_service              = true,
  String[1] $service_name                 = 'trove',
  String[1] $service_type                 = 'database',
  String[1] $service_description          = 'Trove Database Service',
  String[1] $region                       = 'RegionOne',
  Keystone::PublicEndpointUrl $public_url = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  Keystone::EndpointUrl $admin_url        = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
  Keystone::EndpointUrl $internal_url     = 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
) {

  include trove::deps

  Keystone::Resource::Service_identity['trove'] -> Anchor['trove::service::end']

  keystone::resource::service_identity { 'trove':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
