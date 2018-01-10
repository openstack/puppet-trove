# == Class: trove::policy
#
# Configure the trove policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for trove
#   Example :
#     {
#       'trove-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'trove-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the trove policy.json file
#   Defaults to /etc/trove/policy.json
#
class trove::policy (
  $policies    = {},
  $policy_path = '/etc/trove/policy.json',
) {

  include ::trove::deps
  include ::trove::params

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path  => $policy_path,
    file_user  => 'root',
    file_group => $::trove::params::group,
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'trove_config': policy_file => $policy_path }

}
