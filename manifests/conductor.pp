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
#   Default: $::os_workers
#
# [*enable_profiler*]
#   (optional) If False fully disable profiling feature.
#   Default: $::os_service_default
#
# [*trace_sqlalchemy*]
#   (optional) If False doesn't trace SQL requests.
#   Default: $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*auth_url*]
#   (optional) Authentication URL.
#   Defaults to undef
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: undef
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to $::os_service_default, it will not log to any file.
#   Default: undef
#
# [*log_dir*]
#    (optional) directory to which trove logs are sent.
#    If set to $::os_service_default, it will not log to any directory.
#    Defaults undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef
#
class trove::conductor(
  $enabled           = true,
  $manage_service    = true,
  $package_ensure    = 'present',
  $conductor_manager = 'trove.conductor.manager.Manager',
  $workers           = $::os_workers,
  $enable_profiler   = $::os_service_default,
  $trace_sqlalchemy  = $::os_service_default,
  # DEPRECATED PARAMETERS
  $auth_url          = undef,
  $debug             = undef,
  $log_file          = undef,
  $log_dir           = undef,
  $use_syslog        = undef,
  $log_facility      = undef,
) {

  include trove::deps
  include trove::params

  # Remove individual config files so that we do not leave any parameters
  # configured by older version
  file { '/etc/trove/trove-conductor.conf':
    ensure  => absent,
    require => Anchor['trove::config::begin'],
    notify  => Anchor['trove::config::end']
  }

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
