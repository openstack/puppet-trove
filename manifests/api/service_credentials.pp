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
#   Defaults to $::os_service_default
#
class trove::api::service_credentials (
  $password,
  $auth_url            = 'http://127.0.0.1:5000',
  $region_name         = 'RegionOne',
  $username            = 'trove',
  $project_name        = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
  $system_scope        = $::os_service_default,
) {

  include trove::deps

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $::os_service_default
    $project_domain_name_real = $::os_service_default
  }

  trove_config {
    'service_credentials/auth_url':            value => $auth_url;
    'service_credentials/username':            value => $username;
    'service_credentials/password':            value => $password, secret => true;
    'service_credentials/project_name':        value => $project_name_real;
    'service_credentials/project_domain_name': value => $project_domain_name_real;
    'service_credentials/system_scope':        value => $system_scope;
    'service_credentials/user_domain_name':    value => $user_domain_name;
    'service_credentials/region_name':         value => $region_name;
  }

}
