module CouchRestRails
  module Views
    extend self

    # Push views to couchdb
    def push(database_name = '*', opts = {})
      
      CouchRestRails.process_database_method(database_name) do |db, response|
        
        full_db_name = [COUCHDB_CONFIG[:db_prefix], File.basename(db), COUCHDB_CONFIG[:db_suffix]].join
        full_db_path = [COUCHDB_CONFIG[:host_path], '/', full_db_name].join
        
        # Default to push all views for the given database
        view_name = opts[:view_name] || '*'
      
        # Default to load views from all design documents
        design_doc_name = opts[:design_doc_name] || '*'
        
        # Check for CouchDB database
        if !COUCHDB_SERVER.databases.include?(full_db_name)
          response << "Database #{db} (#{full_db_name}) does not exist"
          next
        end
        
        # Check for views directory
        unless File.exist?(File.join(RAILS_ROOT, CouchRestRails.views_path, db))
          response << "Views directory (#{CouchRestRails.views_path}/#{db}) does not exist" 
          next
        end
        
        # Assemble views for each design document
        db_conn = CouchRest.database(full_db_path)
        
        Dir.glob(File.join(RAILS_ROOT, CouchRestRails.views_path, db, "views", design_doc_name)).each do |doc|
        
          views = {}
          couchdb_design_doc = db_conn.get("_design/#{File.basename(doc)}") rescue nil
          Dir.glob(File.join(doc, view_name)).each do |view|
          
            # Load view from filesystem 
            map_reduce = assemble_view(view)
            if map_reduce.empty?
              response << "No view files were found in #{CouchRestRails.views_path}/#{db}/views/#{File.basename(doc)}/#{File.basename(view)}" 
              next
            else
              views[File.basename(view)] = map_reduce
            end

            # Warn if overwriting views on Couch 
            if couchdb_design_doc && couchdb_design_doc['views'] && couchdb_design_doc['views'][File.basename(view)]
              response << "Overwriting existing view '#{File.basename(view)}' in _design/#{File.basename(doc)}"
            end

          end
        
          # Merge with existing views
          views = couchdb_design_doc['views'].merge!(views) unless couchdb_design_doc.nil?
        
          # Save or update
          if couchdb_design_doc.nil?
            couchdb_design_doc = {
              "_id" => "_design/#{File.basename(doc)}", 
              'language' => 'javascript',
              'views' => views
            }
          else
            couchdb_design_doc['views'] = views
          end
          db_conn.save_doc(couchdb_design_doc)

          response << "Pushed views to #{full_db_name}/_design/#{File.basename(doc)}: #{views.keys.join(', ')}"
        
        end
        
      end
    
    end

    # Assemble views 
    def assemble_view(design_doc_path)
      view = {}
      map_file    = File.join(design_doc_path, 'map.js')
      reduce_file = File.join(design_doc_path, 'reduce.js')
      view[:map]    = IO.read(map_file)    if File.exist?(map_file)
      view[:reduce] = IO.read(reduce_file) if File.exist?(reduce_file) && File.size(reduce_file) > 0
      view
    end
    
  end
end
