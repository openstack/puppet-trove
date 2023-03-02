# == Class: trove::params
#
# Parameters for puppet-trove
#
class trove::params {
  include openstacklib::defaults

  $client_package_name = 'python3-troveclient'
  $user                = 'trove'
  $group               = 'trove'

  case $facts['os']['family'] {
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
      $trove_wsgi_script_dir    = '/var/www/cgi-bin/trove'
      $trove_wsgi_script_source = '/usr/bin/trove-wsgi'
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
      $trove_wsgi_script_dir    = '/usr/lib/cgi-bin/trove'
      $trove_wsgi_script_source = '/usr/bin/trove-wsgi'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }

  } # Case $facts['os']['family']
}
