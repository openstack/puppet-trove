Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-trove.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

puppet-trove
=============

#### Table of Contents

1. [Overview - What is the trove module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with trove](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)
8. [Release Notes - Release notes for the project](#release-notes)
9. [Repository - The project source code repository](#repository)

Overview
--------

The trove module is a part of [OpenStack](https://opendev.org/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects as part of the core software. The module itself is used to flexibly configure and manage the database service for OpenStack.

Module Description
------------------

Setup
-----

**What the trove module affects:**

* [trove](https://docs.openstack.org/trove/latest/), the database service for OpenStack.

### Installing trove

    puppet module install openstack/trove

Implementation
--------------

### trove

trove is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### trove_config

The `trove_config` provider is a child of the ini_setting provider. It allows one to write an entry in the `/etc/trove/trove.conf` file.

```puppet
trove_config { 'DEFAULT/backlog' :
  value => 4096,
}
```

This will write `backlog=4096` in the `[DEFAULT]` section.

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
trove_guestagent_config { 'DEFAULT/trove_auth_url' :
  value => http://localhost:5000/v3,
}
```

This will write `trove_auth_url=http://localhost:5000/v3` in the `[DEFAULT]` section.

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

For security reasons, a separate in-cloud RabbitMQ cluster should be set up for trove to use. The reason for this is that the guest agent needs to communicate with RabbitMQ, so it is not advisable to give instances access to the same RabbitMQ server that the core OpenStack services are using for communication.

Please note that puppet-trove cannot check if this rule is being followed, so it is the deployer's responsibility to do it.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://docs.openstack.org/puppet-openstack-guide/latest/

Contributors
------------

* https://github.com/enovance/puppet-trove/graphs/contributors

Release Notes
-------------

* https://docs.openstack.org/releasenotes/puppet-trove

Repository
----------

* https://opendev.org/openstack/puppet-trove
