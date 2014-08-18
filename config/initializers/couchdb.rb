begin

  settings = CouchSettings.instance

  COUCHDB_CONFIG = {
    :host_path => settings.uri.to_s,
    :db_prefix => settings.db_prefix,
    :db_suffix => settings.db_suffix
  }
  COUCHDB_SERVER = CouchRest.new settings.uri.to_s

rescue => e

  STDERR.puts <<-END
    There was a problem with your config/couchdb.yml file. Check and make sure it's present and the syntax is correct.
    If it is not present copy couchdb.yml.example and save it as couchdb.yml. Do not checkin couchdb.yml(any ways its gitignored)
    ***************************
    Its recommended to run the rake task db:create_couch_sysadmin if you have fixed couchdb's admin party!
END

  raise e

end
