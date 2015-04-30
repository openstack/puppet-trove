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
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The trove module is a part of [Stackforge](https://github.com/stackforge), an effort by the Openstack infrastructure team to provide continuous integration testing and code review for Openstack and Openstack community projects not part of the core software. The module itself is used to flexibly configure and manage the database service for Openstack.

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

Release Notes
-------------

