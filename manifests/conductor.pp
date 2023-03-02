# == Class: trove::conductor
#
# Manages trove conductor package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove-conductor service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*package_ensure*]
#   (optional) The state of the trove conductor package
#   Defaults to 'present'
#
# [*conductor_manager*]
#   (optional) Trove conductor manager.
#   Defaults to 'trove.conductor.manager.Manager'.
#
# [*workers*]
#   (optional) Number of trove conductor worker processes to start
#   Default: $facts['os_workers']
#
# [*enable_profiler*]
#   (optional) If False fully disable profiling feature.
#   Default: $facts['os_service_default']
#
# [*trace_sqlalchemy*]
#   (optional) If False doesn't trace SQL requests.
#   Default: $facts['os_service_default']
#
class trove::conductor(
  $enabled           = true,
  $manage_service    = true,
  $package_ensure    = 'present',
  $conductor_manager = 'trove.conductor.manager.Manager',
  $workers           = $facts['os_workers'],
  $enable_profiler   = $facts['os_service_default'],
  $trace_sqlalchemy  = $facts['os_service_default'],
) {

  include trove::deps
  include trove::params

  # basic service config
  trove_config {
    'DEFAULT/trove_conductor_workers': value => $workers;
  }

  # profiler config
  trove_config {
    'profiler/enabled':          value => $enable_profiler;
    'profiler/trace_sqlalchemy': value => $trace_sqlalchemy;
  }

  trove::generic_service { 'conductor':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::conductor_package_name,
    service_name   => $::trove::params::conductor_service_name,
    package_ensure => $package_ensure,
  }

}
