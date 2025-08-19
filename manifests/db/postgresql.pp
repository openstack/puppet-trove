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
class trove::db::postgresql (
  String[1] $password,
  $dbname     = 'trove',
  $user       = 'trove',
  $encoding   = undef,
  $privileges = 'ALL',
) {
  include trove::deps

  openstacklib::db::postgresql { 'trove':
    password   => $password,
    dbname     => $dbname,
    user       => $user,
    encoding   => $encoding,
    privileges => $privileges,
  }

  Anchor['trove::db::begin']
  ~> Class['trove::db::postgresql']
  ~> Anchor['trove::db::end']
}
