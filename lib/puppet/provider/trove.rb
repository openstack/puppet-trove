# Add openstacklib code to $LOAD_PATH so that we can load this during
# standalone compiles without error.
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'

class Puppet::Provider::Trove < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  def self.request(service, action, properties=nil)
    begin
      super
    rescue Puppet::Error::OpenstackAuthInputError => error
      trove_request(service, action, error, properties)
    end
  end

  def self.trove_request(service, action, error, properties=nil)
    properties ||= []
    @credentials.username = trove_credentials['username']
    @credentials.password = trove_credentials['password']
    @credentials.project_name = trove_credentials['project_name']
    @credentials.auth_url = auth_endpoint
    @credentials.user_domain_name = trove_credentials['user_domain_name']
    @credentials.project_domain_name = trove_credentials['project_domain_name']
    if trove_credentials['region_name']
      @credentials.region_name = trove_credentials['region_name']
    end
    raise error unless @credentials.set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials)
  end

  def self.conf_filename
    '/etc/trove/trove.conf'
  end

  def self.trove_conf
    return @trove_conf if @trove_conf
    @trove_conf = Puppet::Util::IniConfig::File.new
    @trove_conf.read(conf_filename)
    @trove_conf
  end

  def self.trove_credentials
    @trove_credentials ||= get_trove_credentials
  end

  def trove_credentials
    self.class.trove_credentials
  end

  def self.get_trove_credentials
    #needed keys for authentication
    auth_keys = ['auth_url', 'project_name', 'username', 'password']
    conf = trove_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      creds = Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
      if !conf['keystone_authtoken']['region_name'].nil?
        creds['region_name'] = conf['keystone_authtoken']['region_name'].strip
      end

      if !conf['keystone_authtoken']['project_domain_name'].nil?
        creds['project_domain_name'] = conf['keystone_authtoken']['project_domain_name'].strip
      else
        creds['project_domain_name'] = 'Default'
      end

      if !conf['keystone_authtoken']['user_domain_name'].nil?
        creds['user_domain_name'] = conf['keystone_authtoken']['user_domain_name'].strip
      else
        creds['user_domain_name'] = 'Default'
      end

      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all " +
            "required sections.  Trove types will not work if trove is not " +
            "correctly configured.")
    end
  end

  def self.conf_filename
    '/etc/trove/trove.conf'
  end

  def self.get_auth_endpoint
    q = trove_credentials
    "#{q['auth_url']}"
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.reset
    @auth_endpoint = nil
    @trove_conf = nil
    @trove_credentials = nil
  end

  def trove_manage(*args)
    cmd = args.join(" ")
    output = `#{cmd}`
    $?.exitstatus
  end
end
