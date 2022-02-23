# DEPRECATED !!
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

  warning('The trove::conductor::service_credentials class has been deprecated and has no effect.')
}
