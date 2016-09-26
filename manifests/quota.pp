# == Class: trove::quota
#
# Setup and configure trove quotas.
#
# === Parameters
#
# [*max_instances_per_tenant*]
#   (optional) Default maximum number of instances per tenant.
#   Defaults to 5.
#
# [*max_accepted_volume_size*]
#   (optional) Default maximum volume size (in GB) for an instance.
#   Defaults to 5.
#
# [*max_volumes_per_tenant*]
#   (optional) Default maximum volume capacity (in GB) spanning across
#   all Trove volumes per tenant.
#   Defaults to 20.
#
# [*max_backups_per_tenant*]
#   (optional) Default maximum number of backups created by a tenant.
#   Defaults to 50.
#
# [*quota_driver*]
#   (optional) Default driver to use for quota checks.
#   Defaults to 'trove.quota.quota.DbQuotaDriver'.
#
# === DEPRECATED PARAMETERS
#
# [*max_instances_per_user*]
#   (optional) DEPRECATED. Default maximum number of instances per tenant.
#   Defaults to undef
#
# [*max_volumes_per_user*]
#   (optional) DEPRECATED. Default maximum volume capacity (in GB) spanning across
#   all Trove volumes per tenant.
#   Defaults to undef
#
# [*max_backups_per_user*]
#   (optional) DEPRECATED. Default maximum number of backups created by a tenant.
#   Defaults to undef
#
class trove::quota (
  $max_instances_per_tenant = 5,
  $max_accepted_volume_size = 5,
  $max_volumes_per_tenant   = 20,
  $max_backups_per_tenant   = 50,
  $quota_driver             = 'trove.quota.quota.DbQuotaDriver',
  # Deprecated
  $max_instances_per_user   = undef,
  $max_volumes_per_user     = undef,
  $max_backups_per_user     = undef,
) {

  include ::trove::deps

  if $max_instances_per_user {
    warning("max_instances_per_user deprecated, has no effect and will be removed after Newton cycle. \
Please use max_instances_per_tenant instead.")
    $max_instances_per_tenant_real = $max_instances_per_user
  } else {
    $max_instances_per_tenant_real = $max_instances_per_tenant
  }

  if $max_volumes_per_user {
    warning("max_volumes_per_user deprecated, has no effect and will be removed after Newton cycle. \
Please use max_volumes_per_tenant instead.")
    $max_volumes_per_tenant_real = $max_volumes_per_user
  } else {
    $max_volumes_per_tenant_real = $max_volumes_per_tenant
  }

  if $max_backups_per_user {
    warning("max_backups_per_user deprecated, has no effect and will be removed after Newton cycle. \
Please use max_backups_per_tenant instead.")
    $max_backups_per_tenant_real = $max_backups_per_user
  } else {
    $max_backups_per_tenant_real = $max_backups_per_tenant
  }

  trove_config {
    'DEFAULT/max_instances_per_tenant': value => $max_instances_per_tenant_real;
    'DEFAULT/max_accepted_volume_size': value => $max_accepted_volume_size;
    'DEFAULT/max_volumes_per_tenant':   value => $max_volumes_per_tenant_real;
    'DEFAULT/max_backups_per_tenant':   value => $max_backups_per_tenant_real;
    'DEFAULT/quota_driver':             value => $quota_driver;
  }
}
