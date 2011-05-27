namespace :couchdb do

  desc "Create a CouchDB database defined in config/couchdb.yml for the current environment (use no database argument to use all databases defined in CouchRestRails::Document models)"
  task :create, :database, :needs => :environment do |t, args|
    args.with_defaults(:database => "*", :opts => {})
    puts CouchRestRails::Database.create(args.database, args.opts)
  end

  desc "Deletes a CouchDB database for the current RAILS_ENV (use no database argument to use all databases defined in CouchRestRails::Document models)"
  task :delete, :database, :needs => :environment do |t, args|
    args.with_defaults(:database => "*", :opts => {})
    puts CouchRestRails::Database.delete(args.database, args.opts)
  end

  namespace :fixtures do
    desc "Load fixtures into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)"
    task :load, :database, :needs  => :environment do |t, args|
      args.with_defaults(:database => "*")
      puts CouchRestRails::Fixtures.load(args.database)
    end
    task :dump, :database, :needs => :environment do |t, args|
      args.with_defaults(:database => "*")
      puts CouchRestRails::Fixtures.dump(args.database)
    end
  end

  namespace :views do
    desc "Push views into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)"
    task :push, :database, :needs => :environment do |t, args|
      args.with_defaults(:database => "*", :opts => {})
      puts CouchRestRails::Views.push(args.database, args.opts)
    end
  end

  namespace :lucene do
    desc "Push Lucene views into a current environment's CouchDB database (use no database argument to use all databases defined in CouchRestRails::Document models)"
    task :push, :database, :needs => :environment do |t, args|
      args.with_defaults(:database => "*", :opts => {})
      puts CouchRestRails::Lucene.push(args.database, args.opts)
    end
  end

end
