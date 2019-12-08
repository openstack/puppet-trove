# This is an example of site.pp to deploy Trove

class { 'trove::client': }

class { 'trove::keystone::auth':
  admin_address    => '10.0.0.1',
  internal_address => '10.0.0.1',
  public_address   => '10.0.0.1',
  password         => 'verysecrete',
  region           => 'OpenStack'
}

class { 'trove::db::mysql':
  password      => 'dbpass',
  host          => '10.0.0.1',
  allowed_hosts => ['10.0.0.1']
}

class { 'trove':
  database_connection   => 'mysql://trove:secrete@10.0.0.1/trove?charset=utf8',
  default_transport_url => 'rabbit://trove:an_even_bigger_secret@10.0.0.1:5672/trove',
  nova_proxy_admin_pass => 'novapass',
}

class { 'trove::api':
  bind_host         => '10.0.0.1',
  auth_url          => 'https://identity.openstack.org:5000/v3',
  keystone_password => 'verysecrete'
}

class { 'trove::conductor':
  auth_url          => 'https://identity.openstack.org:5000/v3'
}

class { 'trove::taskmanager':
  auth_url          => 'https://identity.openstack.org:5000/v3'
}
