require 'restclient'
begin

  env = ENV['RAILS_ENV'] || 'development'

  couchdb_config = YAML::load(ERB.new(Rails.root.join("config", "couchdb.yml").read).result)[env]

  host      = couchdb_config["host"]      || 'localhost'
  port      = couchdb_config["port"]      || '5984'
  database  = couchdb_config["database"]
  username  = couchdb_config["username"]  || 'rapidftr'
  password  = couchdb_config["password"]  || 'rapidftr'
  ssl       = couchdb_config["ssl"]       || false
  db_prefix = database == "_users" ? "" : couchdb_config["database_prefix"]
  db_suffix = database == "_users" ? "" : couchdb_config["database_suffix"]
  host     = "localhost"  if host == nil
  port     = "5984"       if port == nil
  ssl      = false        if ssl == nil

  protocol = ssl ? 'https' : 'http'

  begin
    RestClient.post 'http://127.0.0.1:5984/_session', 'name=rapidftr&password=rapidftr', {:content_type => 'application/x-www-form-urlencoded'}
  rescue RestClient::Request::Unauthorized
    full_host = "#{protocol}://#{host}:#{port}/_config/admins/#{username}"
    RestClient.put full_host, "\""+password+"\"", {:content_type => :json}
  end
  authorized_host = "#{CGI.escape(username)}:#{CGI.escape(password)}@#{host}"
rescue
  raise "There was a problem with your config/couchdb.yml file. Check and make sure it's present and the syntax is correct."
else
  COUCHDB_CONFIG = {
    :host_path => "#{protocol}://#{authorized_host}:#{port}",
    :db_prefix => "#{db_prefix}",
    :db_suffix => "#{db_suffix}"
  }

  COUCHDB_SERVER = CouchRest.new COUCHDB_CONFIG[:host_path]
end
