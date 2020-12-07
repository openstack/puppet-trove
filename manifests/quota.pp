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
# [*max_ram_per_tenant*]
#   (optional) Default maximum amount of RAM (in MB) per tenant.
#   Defaults to -1.
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
class trove::quota (
  $max_instances_per_tenant = 5,
  $max_ram_per_tenant       = -1,
  $max_accepted_volume_size = 5,
  $max_volumes_per_tenant   = 20,
  $max_backups_per_tenant   = 50,
  $quota_driver             = 'trove.quota.quota.DbQuotaDriver',
) {

  include trove::deps

  trove_config {
    'DEFAULT/max_instances_per_tenant': value => $max_instances_per_tenant;
    'DEFAULT/max_ram_per_tenant':       value => $max_ram_per_tenant;
    'DEFAULT/max_accepted_volume_size': value => $max_accepted_volume_size;
    'DEFAULT/max_volumes_per_tenant':   value => $max_volumes_per_tenant;
    'DEFAULT/max_backups_per_tenant':   value => $max_backups_per_tenant;
    'DEFAULT/quota_driver':             value => $quota_driver;
  }
}
