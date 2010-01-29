module CouchRestRails

  mattr_accessor :lucene_path
  self.lucene_path = 'db/couch'

  mattr_accessor :fixtures_path
  self.fixtures_path = 'test/fixtures/couch'
  
  mattr_accessor :test_environment
  self.test_environment = 'test'
  
  mattr_accessor :use_lucene
  self.use_lucene = false
  
  mattr_accessor :views_path
  self.views_path = 'db/couch'
  
  def process_database_method(database_name, &block)
    # If wildcard passed, use model definitions for database names
    if database_name == '*'
      databases = CouchRestRails::Database.list
    else
      databases = [database_name]
    end
    response = ['']
    databases.each do |database|
      yield database, response
    end
    response << ''
    response.join("\n")
  end
  
  module_function :process_database_method
  
end
