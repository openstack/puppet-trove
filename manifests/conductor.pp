# == Class: trove::conductor
#
# Manages trove conductor package and service
#
# === Parameters:
#
# [*enabled*]
#   (optional) Whether to enable the trove-conductor service
#   Defaults to false
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ensure_package*]
#   (optional) The state of the trove conductor package
#   Defaults to 'present'
#
class trove::conductor(
  $enabled        = false,
  $manage_service = true,
  $ensure_package = 'present'
) {

  include trove::params

  trove::generic_service { 'conductor':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_name   => $::trove::params::conductor_package_name,
    service_name   => $::trove::params::conductor_service_name,
    ensure_package => $ensure_package,
  }

}
