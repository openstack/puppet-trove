require 'json'
require 'puppet/util/inifile'

class Puppet::Provider::Trove < Puppet::Provider

  def self.conf_filename
    '/etc/trove/trove.conf'
  end

  def self.withenv(hash, &block)
    saved = ENV.to_hash
    hash.each do |name, val|
      ENV[name.to_s] = val
    end

    yield
  ensure
    ENV.clear
    saved.each do |name, val|
      ENV[name] = val
    end
  end

  def self.trove_credentials
    @trove_credentials ||= get_trove_credentials
  end

  def self.get_trove_credentials
    auth_keys = ['auth_uri', 'project_name', 'username', 'password']
    conf = trove_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      return Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Trove types will not work if trove is not \
correctly configured.")
    end
  end

  def trove_credentials
    self.class.trove_credentials
  end

  def self.trove_conf
    return @trove_conf if @trove_conf
    @trove_conf = Puppet::Util::IniConfig::File.new
    @trove_conf.read(conf_filename)
    @trove_conf
  end

  def self.auth_trove(*args)
    q = trove_credentials
    authenv = {
      :OS_AUTH_URL    => q['auth_uri'],
      :OS_USERNAME    => q['username'],
      :OS_PROJECT_NAME => q['project_name'],
      :OS_PASSWORD    => q['password']
    }
    begin
      withenv authenv do
        trove(args)
      end
    rescue Exception => e
      if (e.message =~ /\[Errno 111\] Connection refused/) or
          (e.message =~ /\(HTTP 400\)/)
        sleep 10
        withenv authenv do
          trove(args)
        end
      else
       raise(e)
      end
    end
  end

  def auth_trove(*args)
    self.class.auth_trove(args)
  end

  def trove_manage(*args)
    cmd = args.join(" ")
    output = `#{cmd}`
    $?.exitstatus
  end

  def self.reset
    @trove_conf        = nil
    @trove_credentials = nil
  end

  def self.list_trove_resources(type, *args)
    json = auth_trove("--json", "#{type}-list", *args)
    return JSON.parse(json)
  end

  def self.get_trove_resource_attrs(type, id)
    json = auth_trove("--json", "#{type}-show", id)
    return JSON.parse(json)
  end

end
