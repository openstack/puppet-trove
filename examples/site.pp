# This is an example of site.pp to deploy Trove

class { 'trove::client': }

class { 'trove::keystone::auth':
  public_url   => 'http://localhost:8779/v1.0/%(tenant_id)s',
  internal_url => 'http://localhost:8779/v1.0/%(tenant_id)s',
  admin_url    => 'http://localhost:8779/v1.0/%(tenant_id)s',
  password     => 'verysecrete',
}

class { 'trove::db::mysql':
  password      => 'dbpass',
  host          => 'localhost',
  allowed_hosts => ['localhost'],
}

class { 'trove::db':
  database_connection => 'mysql://trove:dbpass@localhost/trove?charset=utf8',
}

class { 'trove':
  default_transport_url => 'rabbit://trove:an_even_bigger_secret@localhost:5672/trove',
}

class { 'trove::service_credentials':
  auth_url => 'https://identity.openstack.org:5000/v3',
  password => 'verysecrete',
}

class { 'trove::conductor::service_credentials':
  password => 'verysecrete',
}

class { 'trove::task_manager::service_credentials':
  password => 'verysecrete',
}

class { 'trove::guestagent::service_credentials':
  auth_url => 'https://identity.openstack.org:5000/v3',
  password => 'verysecrete',
}

class { 'trove::keystone::authtoken':
  auth_url => 'https://identity.openstack.org:5000/v3',
  password => 'verysecrete',
}

class { 'trove::api':
  bind_host => '10.0.0.1',
}

class { 'trove::conductor': }

class { 'trove::taskmanager': }
