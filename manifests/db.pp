# == Class: trove::db
#
#  Configure the Trove database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/trove/trove.sqlite'.
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to 3600.
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to 10.
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to 10.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to 10.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to 20.
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# [*mysql_enable_ndb*]
#   (Optional) If True, transparently enables support for handling MySQL
#   Cluster (NDB).
#   Defaults to $::os_service_default
#
class trove::db (
  $database_connection              = 'sqlite:////var/lib/trove/trove.sqlite',
  $database_connection_recycle_time = $::os_service_default,
  $database_max_pool_size           = $::os_service_default,
  $database_max_retries             = $::os_service_default,
  $database_retry_interval          = $::os_service_default,
  $database_max_overflow            = $::os_service_default,
  $database_pool_timeout            = $::os_service_default,
  $mysql_enable_ndb                 = $::os_service_default,
) {

  include trove::deps

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use trove::<myparam> if trove::db::<myparam> isn't specified.
  $database_connection_real              = pick($::trove::database_connection, $database_connection)
  $database_connection_recycle_time_real = pick($::trove::database_idle_timeout, $database_connection_recycle_time)
  $database_max_pool_size_real           = pick($::trove::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real             = pick($::trove::database_max_retries, $database_max_retries)
  $database_retry_interval_real          = pick($::trove::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real            = pick($::trove::database_max_overflow, $database_max_overflow)

  oslo::db { 'trove_config':
    connection              => $database_connection_real,
    connection_recycle_time => $database_connection_recycle_time_real,
    max_pool_size           => $database_max_pool_size_real,
    max_retries             => $database_max_retries_real,
    retry_interval          => $database_retry_interval_real,
    max_overflow            => $database_max_overflow_real,
    pool_timeout            => $database_pool_timeout,
    mysql_enable_ndb        => $mysql_enable_ndb,
  }
}
