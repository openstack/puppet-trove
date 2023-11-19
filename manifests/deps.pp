# == Class: trove::deps
#
#  trove anchors and dependency management
#
class trove::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'trove::install::begin': }
  -> Package<| tag == 'trove-package'|>
  ~> anchor { 'trove::install::end': }
  -> anchor { 'trove::config::begin': }
  -> Trove_config<||>
  ~> anchor { 'trove::config::end': }
  -> anchor { 'trove::db::begin': }
  -> anchor { 'trove::db::end': }
  ~> anchor { 'trove::dbsync::begin': }
  -> anchor { 'trove::dbsync::end': }
  ~> anchor { 'trove::service::begin': }
  ~> Service<| tag == 'trove-service' |>
  ~> anchor { 'trove::service::end': }

  # Include all the other trove config pieces in the config block.
  # Don't put them above because there's no chain between each individual part
  # of the config.
  Anchor['trove::config::begin']
  -> Trove_guestagent_config<||>
  ~> Anchor['trove::config::end']

  # Also include paste ini config in the config section
  Anchor['trove::config::begin']
  -> Trove_api_paste_ini<||>
  ~> Anchor['trove::config::end']

  # policy config should occur in the config block also as soon as
  # puppet-trove supports it. Leave commented out for now.
  Anchor['trove::config::begin']
  -> Openstacklib::Policy<| tag == 'trove' |>
  -> Anchor['trove::config::end']

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db<||> -> Anchor['trove::dbsync::begin']

  # We need openstackclient installed before marking service end so that trove
  # will have clients available to create resources. This tag handles the
  # openstackclient but indirectly since the client is not available in
  # all catalogs that don't need the client class (like many spec tests).
  # Once the openstackclient is installed we will setup the datastores and
  # datastore_versions. Datastore_versions must come after datastores.
  Package<| tag == 'openstackclient'|>
  -> Anchor['trove::service::end']

  # Installation or config changes will always restart services.
  Anchor['trove::install::end'] ~> Anchor['trove::service::begin']
  Anchor['trove::config::end']  ~> Anchor['trove::service::begin']
}
