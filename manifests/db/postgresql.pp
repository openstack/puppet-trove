# == Class: trove::db::postgresql
#
# Manage the trove postgresql database
#
# === Parameters:
#
# [*password*]
#   (required) Password that will be used for the trove db user.
#
# [*dbname*]
#   (optionnal) Name of trove database.
#   Defaults to trove
#
# [*user*]
#   (optionnal) Name of trove user.
#   Defaults to trove
#
class trove::db::postgresql(
  $password,
  $dbname    = 'trove',
  $user      = 'trove'
) {

  require postgresql::python

  Class['trove::db::postgresql'] -> Service<| title == 'trove' |>
  Postgresql::Db[$dbname] ~> Exec<| title == 'trove-manage db_sync' |>
  Package['python-psycopg2'] -> Exec<| title == 'trove-manage db_sync' |>


  postgresql::db { $dbname:
    user      => $user,
    password  => $password,
  }

}
