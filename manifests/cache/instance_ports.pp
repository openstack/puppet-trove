# == Class: trove::cache::instance_ports
#
# Configure instance_ports_cache options
#
# === Parameters
#
# [*expiration_time*]
#   (Optional) TTL, in seconds, for any cached item in the dogpile.cache region
#   used for caching of the instance ports.
#   Defaults to $facts['os_service_default']
#
# [*caching*]
#   (Optional) Toggle to enable/disable caching when getting trove instance
#   ports.
#   Defaults to $facts['os_service_default']
#
class trove::cache::instance_ports (
  $expiration_time = $facts['os_service_default'],
  $caching         = $facts['os_service_default'],
) {
  include trove::deps

  trove_config {
    'instance_ports_cache/expiration_time': value => $expiration_time;
    'instance_ports_cache/caching':         value => $caching;
  }
}
