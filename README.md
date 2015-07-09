puppet-trove
=============

6.0.0 - 2015.1 - Kilo

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

* trove, the database service for Openstack.

Implementation
--------------

### trove

trove is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

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
