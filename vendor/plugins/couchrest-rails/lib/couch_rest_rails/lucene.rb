require 'json'

module CouchRestRails
  module Lucene
    extend self


    # Push Lucene searches to couchdb
    def push(database_name = '*', opts = {})

      CouchRestRails.process_database_method(database_name) do |db, response|

        full_db_name = [COUCHDB_CONFIG[:db_prefix], File.basename(db), COUCHDB_CONFIG[:db_suffix]].join
        full_db_path = [COUCHDB_CONFIG[:host_path], '/', full_db_name].join

        # Default to push all Lucene searches for the given database
        search_name = opts[:search_name] || '*'

        # Default to load searches from all design documents
        design_doc_name = opts[:design_doc_name] || '*'

        # Check for CouchDB database
        if !COUCHDB_SERVER.databases.include?(full_db_name)
          response << "Database #{db} (#{full_db_name}) does not exist"
          next
        end

        # Check for views directory
        unless File.exist?(File.join(RAILS_ROOT, CouchRestRails.lucene_path, db))
          response << "Lucene directory (#{CouchRestRails.lucene_path}/#{db}) does not exist" 
          next
        end

        # Assemble searches for each design document
        db_conn = CouchRest.database(full_db_path)

        Dir.glob(File.join(RAILS_ROOT, CouchRestRails.lucene_path, db, "lucene", design_doc_name)).each do |doc|

          searches = {}
          couchdb_design_doc = db_conn.get("_design/#{File.basename(doc)}") rescue nil
          
          searches = assemble_lucene_searches(doc)
          
          # Warn if overwriting existing search
          if couchdb_design_doc && couchdb_design_doc['fulltext']
            searches.keys.each do |search|
              if couchdb_design_doc['fulltext'][search]
                response << "Overwriting existing Lucene search '#{search}' in _design/#{File.basename(doc)}"
              end
            end
          end

          # Save or update
          if couchdb_design_doc.nil?
            couchdb_design_doc = {
              "_id" => "_design/#{File.basename(doc)}", 
              'language' => 'javascript',
              'fulltext' => searches
            }
          else
            if couchdb_design_doc['fulltext']
              # Merge with existing searches
              searches = couchdb_design_doc['fulltext'].merge!(searches)
            end
            couchdb_design_doc['fulltext'] = searches
          end
          db_conn.save_doc(couchdb_design_doc)

          response << "Pushed Lucene searches to #{full_db_name}/_design/#{File.basename(doc)}: #{searches.keys.join(', ')}"

        end

      end

    end

    # Assemble Lucene searches 
    def assemble_lucene_searches(lucene_doc_path)
      searches = {}
      Dir.glob(File.join(lucene_doc_path, '*')).each do |search_file|
        search_name = File.basename(search_file).sub(/\.js$/, '')
        searches[search_name] = JSON.parse(IO.read(search_file).gsub(/\n/, ''))
      end
      searches
    end

  end
end
