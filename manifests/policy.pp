# == Class: trove::policy
#
# Configure the trove policies
#
# === Parameters
#
# [*enforce_scope*]
#  (Optional) Whether or not to enforce scope when evaluating policies.
#  Defaults to $::os_service_default.
#
# [*enforce_new_defaults*]
#  (Optional) Whether or not to use old deprecated defaults when evaluating
#  policies.
#  Defaults to $::os_service_default.
#
# [*policies*]
#   (Optional) Set of policies to configure for trove
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
#   (Optional) Path to the trove policy.yaml file
#   Defaults to /etc/trove/policy.yaml
#
class trove::policy (
  $enforce_scope        = $::os_service_default,
  $enforce_new_defaults = $::os_service_default,
  $policies             = {},
  $policy_path          = '/etc/trove/policy.yaml',
) {

  include trove::deps
  include trove::params

  validate_legacy(Hash, 'validate_hash', $policies)

  Openstacklib::Policy::Base {
    file_path   => $policy_path,
    file_user   => 'root',
    file_group  => $::trove::params::group,
    file_format => 'yaml',
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'trove_config':
    enforce_scope        => $enforce_scope,
    enforce_new_defaults => $enforce_new_defaults,
    policy_file          => $policy_path
  }

}
