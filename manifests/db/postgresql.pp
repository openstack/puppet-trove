# == Class: trove::db::postgresql
#
# Class that configures postgresql for trove
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'trove'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'trove'.
#
# [*encoding*]
#   (Optional) The charset to use for the database.
#   Default to undef.
#
# [*privileges*]
#   (Optional) Privileges given to the database user.
#   Default to 'ALL'
#
class trove::db::postgresql(
  $password,
  $dbname     = 'trove',
  $user       = 'trove',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  include ::trove::deps

  validate_string($password)

  ::openstacklib::db::postgresql { 'trove':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  Anchor['trove::db::begin']
  ~> Class['trove::db::postgresql']
  ~> Anchor['trove::db::end']
}
