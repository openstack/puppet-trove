# The trove::api::service_credentials class helps configure auth settings
#
# == Parameters
#
# [*password*]
#   (required) the keystone password for trove services
#
# [*auth_url*]
#   (optional) the keystone public endpoint
#   Defaults to 'http://127.0.0.1:5000'
#
# [*region_name*]
#   (optional) the keystone region of this node
#   Defaults to 'RegionOne'
#
# [*username*]
#   (optional) the keystone user for trove services
#   Defaults to 'trove'
#
# [*project_name*]
#   (optional) the keystone tenant name for trove services
#   Defaults to 'services'
#
# [*project_domain_name*]
#   (optional) the keystone project domain name for trove services
#   Defaults to 'Default'
#
# [*user_domain_name*]
#   (optional) the keystone user domain name for trove services
#   Defaults to 'Default'
#
# [*system_scope*]
#   (optional) Scope for system operations.
#   Defaults to $facts['os_service_default']
#
class trove::api::service_credentials (
  $password,
  $auth_url            = 'http://127.0.0.1:5000',
  $region_name         = 'RegionOne',
  $username            = 'trove',
  $project_name        = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
  $system_scope        = $facts['os_service_default'],
) {

  include trove::deps

  warning("The trove::api::service_credentials class is deprecated. \
Use the trove::service_credentials class instead.")

  class { 'trove::service_credentials':
    password            => $password,
    auth_url            => $auth_url,
    region_name         => $region_name,
    username            => $username,
    project_name        => $project_name,
    project_domain_name => $project_domain_name,
    user_domain_name    => $user_domain_name,
    system_scope        => $system_scope,
  }
}
