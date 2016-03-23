## 8.0.0 and beyond

From 8.0.0 release and beyond, release notes are published on
[docs.openstack.org](http://docs.openstack.org/releasenotes/puppet-trove/).

##2015-11-25 - 7.0.0
###Summary

This is a backwards-compatible major release for OpenStack Liberty.

####Features
- add tag to package and service resources
- add trove::config class
- reflect provider change in puppet-openstacklib
- introduce trove::quota class
- introduce use_guestagent_template option
- make taskmanager_queue option configurable
- add api ratelimit options
- add region and resource url related options
- add default_neutron_networks in trove::taskmanager
- complete qpid support
- keystone/auth: make service description configurable

####Bugfixes
- fix rabbit_userid parameter
- fix default value of guestagent_config_file option

####Maintenance
- initial msync run for all Puppet OpenStack modules
- try to use zuul-cloner to prepare fixtures
- remove class_parameter_defaults puppet-lint check
- acceptance: use common bits from puppet-openstack-integration
- acceptance: enable debug & verbosity for OpenStack logs
- fix rspec 3.x syntax

##2015-10-10 - 6.1.0
###Summary

This is a feature and bugfix release in the Kilo series.

####Features
- Introduce trove:config to manage custom options

####Maintenance
- acceptance: checkout stable/kilo puppet modules

####Bugfixes
- Fix catalog compilation when not configuring endpoint

##2015-07-08 - 6.0.0
###Summary

- Initial release of the puppet-trove module
