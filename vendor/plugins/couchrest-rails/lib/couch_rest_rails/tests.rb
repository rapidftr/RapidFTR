module CouchRestRails
  module Tests

    extend self
    mattr_accessor :fixtures_loaded
    self.fixtures_loaded = Set.new

    def setup(database_name = '*', opts = {})
      Rails.env = CouchRestRails.test_environment
      unless opts[:skip_if_fixtures_loaded] && fixtures_loaded.include?(database_name)
        server = CouchRest::Server.new(COUCHDB_CONFIG[:host_path])
        test_databases = server.databases.select{|database| database.include?("_test")}
        test_databases.each{|test_db| CouchRest::Database.new(server, test_db).delete!}
        test_databases.each{|test_db| server.create_db(test_db)}
      end
    end

    def reset_fixtures
      CouchRestRails::Database.delete("*") unless fixtures_loaded.empty?
      fixtures_loaded.clear
    end

    def teardown(database_name = "*")
      ENV['RAILS_ENV'] = CouchRestRails.test_environment
      CouchRestRails::Database.delete(database_name)
      fixtures_loaded.delete(database_name)
    end
  end
end
module Test
  module Unit #:nodoc:
    class TestCase #:nodoc:

      setup :setup_couchdb_fixtures if defined?(setup)
      teardown :teardown_couchdb_fixtures if defined?(teardown)

      superclass_delegating_accessor :database
      self.database = nil

      class << self
        def couchdb_fixtures(*databases)
          self.database = databases.map { |d| d.to_s }
        end
      end
      def setup_couchdb_fixtures
        CouchRestRails::Tests.setup(self.database) unless self.database.nil?
      end
      def teardown_couchdb_fixtures
        CouchRestRails::Tests.teardown(self.database) unless self.database.nil?
      end
    end
  end
end
