# == Class trove::guestagent::mysql
#
# Configure the mysql options
#
# == Parameters
#
# [*docker_image*]
#   (optional) Database docker image.
#   Defaults to $facts['os_service_default']
#
# [*backup_docker_image*]
#   (optional) The docker image used for backup and restore.
#   Defaults to $facts['os_service_default']
#
# [*root_on_create*]
#   (optional) Enable the automatic creation of the root user for the service
#   during instance-create.
#   Defaults to $facts['os_service_default']
#
# [*usage_timeout*]
#   (optional) Maximum time (in seconds) to wait for a Guest to become active.
#   Defaults to $facts['os_service_default']
#
# [*volume_support*]
#   (optional) Whether to provision a Cinder volume for datadir
#   Defaults to $facts['os_service_default']
#
# [*ignore_users*]
#   (optional) Users to exclude when listing users.
#   Defaults to $facts['os_service_default']
#
# [*ignore_dbs*]
#   (optional) Databases to exclude when listing databases.
#   Defaults to $facts['os_service_default']
#
# [*guest_log_exposed_logs*]
#   (optional) List of Guest Logs to expose for publishing.
#   Defaults to $facts['os_service_default']
#
# [*default_password_length*]
#   (optional) Character length of generated passwords.
#   Defaults to $facts['os_service_default']
#
# DEPRECATED PARAMETERS
#
# [*guest_log_long_query_time*]
#   (optional) The time in milliseconds that a statement must take in in order
#   to be logged in the slow_query log.
#   Defaults to undef
#
# [*icmp*]
#   (optional) Whether to permit ICMP.
#   Defaults to undef
#
class trove::guestagent::mysql (
  $docker_image              = $facts['os_service_default'],
  $backup_docker_image       = $facts['os_service_default'],
  $root_on_create            = $facts['os_service_default'],
  $usage_timeout             = $facts['os_service_default'],
  $volume_support            = $facts['os_service_default'],
  $ignore_users              = $facts['os_service_default'],
  $ignore_dbs                = $facts['os_service_default'],
  $guest_log_exposed_logs    = $facts['os_service_default'],
  $default_password_length   = $facts['os_service_default'],
  # DEPRECATED PARAMETERS
  $guest_log_long_query_time = undef,
  $icmp                      = undef,
) {

  include trove::deps

  if $guest_log_long_query_time != undef {
    warning('The guest_log_long_query_time parameter is deprecated.')
  }
  if $icmp != undef {
    warning('The icmp parameter is deprecated.')
  }

  trove_guestagent_config {
    'mysql/docker_image':              value => $docker_image;
    'mysql/backup_docker_image':       value => $backup_docker_image;
    'mysql/icmp':                      value => pick($icmp, $facts['os_service_default']);
    'mysql/root_on_create':            value => $root_on_create;
    'mysql/usage_timeout':             value => $usage_timeout;
    'mysql/volume_support':            value => $volume_support;
    'mysql/ignore_users':              value => join(any2array($ignore_users), ',');
    'mysql/ignore_dbs':                value => join(any2array($ignore_dbs), ',');
    'mysql/guest_log_exposed_logs':    value => join(any2array($guest_log_exposed_logs), ',');
    'mysql/guest_log_long_query_time': value => pick($guest_log_long_query_time, $facts['os_service_default']);
    'mysql/default_password_length':   value => $default_password_length;
  }

}
