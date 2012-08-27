module CouchRestRails
  module Database

    extend self
    
    def create(database_name = '*', opts = {})
      
      CouchRestRails.process_database_method(database_name) do |db, response|
        
        # Setup up views directory
        database_views_path = File.join(RAILS_ROOT, CouchRestRails.views_path, db, 'views')
        unless File.exist?(database_views_path)
          FileUtils.mkdir_p(database_views_path)
          response << "Created #{File.join(CouchRestRails.views_path, db, 'views')} views directory"
        end
        
        # Setup the Lucene directory if enabled
        if CouchRestRails.use_lucene
          database_lucene_path = File.join(RAILS_ROOT, CouchRestRails.lucene_path, db, 'lucene')
          unless File.exist?(database_lucene_path)
            FileUtils.mkdir_p(database_lucene_path)
            response << "Created #{File.join(CouchRestRails.lucene_path, db, 'lucene')} Lucene directory"
          end
        end
        
        full_db_name = [COUCHDB_CONFIG[:db_prefix], File.basename(db), COUCHDB_CONFIG[:db_suffix]].join
        
        # Warn if no model uses the database
        unless CouchRestRails::Database.list.include?(db)
          response << "WARNING: there are no CouchRestRails::Document models using #{db}"
        end
        
        # Create the database
        if COUCHDB_SERVER.databases.include?(full_db_name)
          response << "Database #{db} (#{full_db_name}) already exists"
          next
        else
          COUCHDB_SERVER.create_db(full_db_name)
          response << "Created database #{db} (#{full_db_name})"
        end
        
      end

    end

    def delete(database_name = '*', opts = {})
      
      CouchRestRails.process_database_method(database_name) do |db, response|
      
        full_db_name = [COUCHDB_CONFIG[:db_prefix], File.basename(db), COUCHDB_CONFIG[:db_suffix]].join
        if !COUCHDB_SERVER.databases.include?(full_db_name)
          response << "Database #{db} (#{full_db_name}) does not exist"
        else
          CouchRest.delete "#{COUCHDB_CONFIG[:host_path]}/#{full_db_name}"
          response << "Deleted database #{db} (#{full_db_name})"
        end
        
        # Warn if views path still present for database
        if File.exist?(File.join(RAILS_ROOT, CouchRestRails.views_path, db, 'views'))
          response << "WARNING: #{File.join(CouchRestRails.views_path, db, 'views')} views path still present"
        end
        
        # Warn if Lucene path still present for database
        if CouchRestRails.use_lucene
          if File.exist?(File.join(RAILS_ROOT, CouchRestRails.lucene_path, db, 'views'))
            response << "WARNING: #{File.join(CouchRestRails.lucene_path, db, 'views')} Lucene path still present"
          end
        end
        
      end

    end

    def list
      databases = []
      # Ensure models are loaded
      Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).map { |m| require_dependency m }
      Object.subclasses_of(CouchRestRails::Document).collect do |doc|
        raise "#{doc.name} does not have a database defined" unless doc.database
        databases << doc.unadorned_database_name
      end
      databases.sort.uniq
    end

  end
end
