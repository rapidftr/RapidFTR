class CouchRestRailsGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.directory "db/couch"
      m.directory "test/fixtures/couch"
      m.template "couchdb.yml", "config/couchdb.yml"
      m.template "couchdb_initializer.rb", "config/initializers/couchdb.rb"
    end
  end

end
