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
#       'trove-context_is_admin' => {'context_is_admin' => 'true'},
#       'trove-default'          => {'default' => 'rule:admin_or_owner'}
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

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)
  oslo::policy { 'trove_config': policy_file => $policy_path }
}
