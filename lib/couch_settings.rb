class CouchSettings

  attr_accessor :path
  attr_accessor :env
  attr_accessor :config

  class << self
    def instance
      @instance ||= new_with_defaults
    end

    def new_with_defaults
      path   = ::Rails.root.join "config", "couchdb.yml"
      env    = ::Rails.env.to_s
      config = YAML.load(ERB.new(File.read(path)).result)[env] rescue {}
      CouchSettings.new(path, env, config)
    end
  end

  def initialize(path, env, config)
    @path = path
    @env = env
    @config = config
  end

  def host
    @config['host'] || 'localhost'
  end

  def http_port
    @config['port'] || '5984'
  end

  def https_port
    @config['https_port'] || '6984'
  end

  def username
    @config['username']
  end

  def password
    @config['password']
  end

  def db_prefix
    @config['prefix'] || "rapidftr"
  end

  def db_suffix
    @config['suffix'] || "#{env}"
  end

  def ssl_enabled_for_rapidftr?
    !(@config["ssl"].blank? or @config["ssl"] == false)
  end

  def port
    ssl_enabled_for_rapidftr? ? https_port : http_port
  end

  def protocol
    ssl_enabled_for_rapidftr? ? "https" : "http"
  end

  def uri
    uri = URI.parse "#{protocol}://#{host}:#{port}"
    uri.user = username if username
    uri.password = password if username && password
    uri
  end

  def with_ssl
    @old_ssl = @config['ssl']
    @config['ssl'] = true
    yield
  ensure
    @config['ssl'] = @old_ssl
  end

  def authenticate(username, password)
    RestClient.post "#{uri}/_session", "name=#{username}&password=#{password}", {:content_type => 'application/x-www-form-urlencoded'}
    true
  end

  def ssl_enabled_for_couch?
    @ssl_enabled_for_couch ||= with_ssl { authenticate username, password } rescue false
  end

  def databases
    COUCHDB_SERVER.databases.select { |db|
      db.starts_with?(db_prefix + "_") && db.ends_with?("_" + db_suffix)
    }.map { |name|
      COUCHDB_SERVER.database(name)
    }
  end

end
