puppet-trove
=============

7.0.0 - 2015.2 - Liberty

#### Table of Contents

1. [Overview - What is the trove module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with trove](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The trove module is a part of [OpenStack](https://github.com/openstack), an effort by the Openstack infrastructure team to provide continuous integration testing and code review for Openstack and Openstack community projects as part of the core software. The module itself is used to flexibly configure and manage the database service for Openstack.

Module Description
------------------

Setup
-----

**What the trove module affects:**

* [Trove](http://docs.openstack.org/developer/trove/), the database service for Openstack.

### Installing trove

    puppet module install openstack/trove

Implementation
--------------

### trove

trove is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### trove_config

The `trove_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/trove/trove.conf` file.

```puppet
trove_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `trove.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

#### trove_conductor_config

The `trove_conductor_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/trove/trove-conductor.conf` file.

```puppet
trove_conductor_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `trove.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

#### trove_guestagent_config

The `trove_guestagent_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/trove/trove-guestagent.conf` file.

```puppet
trove_guestagent_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `trove.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

#### trove_taskmanager_config

The `trove_taskmanager_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/trove/trove-taskmanager.conf` file.

```puppet
trove_taskmanager_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `trove.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
-----------

Security
--------

For security reasons, a separate in-cloud RabbitMQ cluster should be set up for Trove to use. The reason for this is that the guest agent needs to communicate with RabbitMQ, so it is not advisable to give instances access to the same RabbitMQ server that the core OpenStack services are using for communication.

Please note that puppet-trove cannot check if this rule is being followed, so it is the deployer's responsibility to do it.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

``shell
bundle install
bundle exec rspec spec/acceptance
``

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/enovance/puppet-trove/graphs/contributors
