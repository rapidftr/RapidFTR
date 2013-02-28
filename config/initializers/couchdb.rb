begin

  env = ENV['RAILS_ENV'] || 'development'

  couchdb_config = YAML::load(ERB.new(Rails.root.join("config", "couchdb.yml").read).result)[env]

  host      = couchdb_config["host"]      || 'localhost'
  port      = couchdb_config["port"]      || '5984'
  database  = couchdb_config["database"]
  username  = couchdb_config["username"]
  password  = couchdb_config["password"]
  ssl       = (couchdb_config["ssl"].blank? or couchdb_config["ssl"] == false) ? false : true
  db_prefix = couchdb_config["database_prefix"] || ""
  db_suffix = couchdb_config["database_suffix"] || ""
  https_port = couchdb_config["https_port"]      || '6984'

  protocol = ssl ? 'https' : 'http'
  authorized_host = (username.blank? && password.blank?) ? host :
    "#{CGI.escape(username)}:#{CGI.escape(password)}@#{host}"
rescue
  raise "There was a problem with your config/couchdb.yml file. Check and make sure it's present and the syntax is correct.
         If it is not present copy couchdb.yml.example and save it as couchdb.yml. Do not checkin couchdb.yml(any ways its gitignored)
         ***************************

         Its recommended to run the rake task db:create_couch_sysadmin if you have fixed couchdb's admin party! "
else

  COUCHDB_CONFIG = {
      :host_path => "#{protocol}://#{authorized_host}:#{port}",
      :db_prefix => "#{db_prefix}",
      :db_suffix => "#{db_suffix}",
      :https_port => https_port,
  }

  COUCHDB_SERVER = CouchRest.new COUCHDB_CONFIG[:host_path]
end
