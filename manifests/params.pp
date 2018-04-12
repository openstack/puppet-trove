# == Class: trove::params
#
# Parameters for puppet-trove
#
class trove::params {
  include ::openstacklib::defaults

  if ($::os_package_type == 'debian') {
    $pyvers = '3'
  } else {
    $pyvers = ''
  }

  $client_package_name = "python${pyvers}-troveclient"
  $group               = 'trove'

  case $::osfamily {
    'RedHat': {
      $common_package_name      = 'openstack-trove'
      $conductor_package_name   = 'openstack-trove-conductor'
      $conductor_service_name   = 'openstack-trove-conductor'
      $api_package_name         = 'openstack-trove-api'
      $api_service_name         = 'openstack-trove-api'
      $guestagent_package_name  = 'openstack-trove-guestagent'
      $guestagent_service_name  = 'openstack-trove-guestagent'
      $taskmanager_package_name = 'openstack-trove-taskmanager'
      $taskmanager_service_name = 'openstack-trove-taskmanager'
    }
    'Debian': {
      $common_package_name      = 'trove-common'
      $conductor_package_name   = 'trove-conductor'
      $conductor_service_name   = 'trove-conductor'
      $api_package_name         = 'trove-api'
      $api_service_name         = 'trove-api'
      $guestagent_package_name  = 'trove-guestagent'
      $guestagent_service_name  = 'trove-guestagent'
      $taskmanager_package_name = 'trove-taskmanager'
      $taskmanager_service_name = 'trove-taskmanager'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
