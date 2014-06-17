# Parameters for puppet-trove
#
class trove::params {

  case $::osfamily {
    'RedHat': {
      $client_package_name      = 'openstack-trove'
      $common_package_name      = 'openstack-trove-common'
      $api_package_name         = 'openstack-trove-api'
      $guestagent_package_name  = 'openstack-trove-guestagent'
      $taskmanager_package_name = 'openstack-trove-taskmanager'
    }
    'Debian': {
      $client_package_name      = 'python-troveclient'
      $common_package_name      = 'trove-common'
      $api_package_name         = 'trove-api'
      $guestagent_package_name  = 'trove-guestagent'
      $taskmanager_package_name = 'trove-taskmanager'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
