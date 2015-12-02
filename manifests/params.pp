# Parameters for puppet-trove
#
class trove::params {

  case $::osfamily {
    'RedHat': {
      $client_package_name      = 'python-troveclient'
      $common_package_name      = 'openstack-trove'
      $conductor_package_name   = 'openstack-trove-conductor'
      $conductor_service_name   = 'openstack-trove-conductor'
      $api_package_name         = 'openstack-trove-api'
      $api_service_name         = 'openstack-trove-api'
      $guestagent_package_name  = 'openstack-trove-guestagent'
      $guestagent_service_name  = 'openstack-trove-guestagent'
      $taskmanager_package_name = 'openstack-trove-taskmanager'
      $taskmanager_service_name = 'openstack-trove-taskmanager'
      $sqlite_package_name      = undef
      $pymysql_package_name     = undef
    }
    'Debian': {
      $client_package_name      = 'python-troveclient'
      $common_package_name      = 'trove-common'
      $conductor_package_name   = 'trove-conductor'
      $conductor_service_name   = 'trove-conductor'
      $api_package_name         = 'trove-api'
      $api_service_name         = 'trove-api'
      $guestagent_package_name  = 'trove-guestagent'
      $guestagent_service_name  = 'trove-guestagent'
      $taskmanager_package_name = 'trove-taskmanager'
      $taskmanager_service_name = 'trove-taskmanager'
      $sqlite_package_name      = 'python-pysqlite2'
      $pymysql_package_name     = 'python-pymysql'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
