# The trove::taskmanager::service_credentials class helps configure auth settings
#
# == Parameters
# [*auth_url*]
#   (optional) the keystone public endpoint
#   Defaults to undef
#
# [*region_name*]
#   (optional) the keystone region of this node
#   Optional. Defaults to 'RegionOne'
#
# [*username*]
#   (optional) the keystone user for trove services
#   Defaults to 'trove'
#
# [*password*]
#   (required) the keystone password for trove services
#
# [*project_name*]
#   (optional) the keystone tenant name for trove services
#   Defaults to 'services'
#
# [*project_domain_name*]
#   (optional) the keystone project domain name for trove services
#   Defaults to 'Default'
#
#  [*user_domain_name*]
#   (optional) the keystone user domain name for trove services
#   Defaults to 'Default'
#
class trove::taskmanager::service_credentials (
  $password            = $::os_service_default,
  $auth_url            = 'http://127.0.0.1:5000/v3',
  $region_name         = 'RegionOne',
  $username            = 'trove',
  $project_name        = 'services',
  $project_domain_name = 'Default',
  $user_domain_name    = 'Default',
) {

  include trove::deps

  $auth_url_base = pick($::trove::taskmanager::auth_url, $auth_url)
  $auth_url_real = "${regsubst($auth_url_base, '(\/v3$|\/v2.0$|\/$)', '')}/v3"

  $username_real      = pick($::trove::nova_proxy_admin_user, $username)
  $password_real      = pick($::trove::nova_proxy_admin_pass, $password)
  $project_name_real  = pick($::trove::nova_proxy_tenant_name, $project_name)
  $region_name_real   = pick($::trove::os_region_name, $region_name)

  if is_service_default($password_real) {
    fail('trove::taskmanager::service_credentials::password should be set')
  }

  trove_taskmanager_config {
    'service_credentials/auth_url':            value => $auth_url_real;
    'service_credentials/username':            value => $username_real;
    'service_credentials/password':            value => $password_real, secret => true;
    'service_credentials/project_name':        value => $project_name_real;
    'service_credentials/project_domain_name': value => $project_domain_name;
    'service_credentials/user_domain_name':    value => $user_domain_name;
    'service_credentials/region_name':         value => $region_name_real;
  }

}
