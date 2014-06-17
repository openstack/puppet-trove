# Parameters for puppet-trove
#
class trove::params {

  case $::osfamily {
    'RedHat': {
      $client_package_name      = 'openstack-trove'
    }
    'Debian': {
      $client_package_name      = 'python-troveclient'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}
