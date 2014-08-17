namespace :db do

  desc "Seed with data (task manually created during the 3.0 upgrade, as it went missing)"
  task :seed => :environment do
    load(Rails.root.join("db", "seeds.rb"))
  end

  task :migrate => :environment do
    Migration.migrate
  end

  task :create_couch_sysadmin, :user_name, :password do |t, args|
    url       = "http://localhost:5984"
    user_name = args[:user_name]
    password  = args[:password]

    begin
      full_host = "#{url}/_config/admins/#{user_name}"
      RestClient.put full_host, "\"" + password + "\"", {:content_type => :json}
      puts "Administrator account #{user_name} has been created"
    rescue
      puts "Administrator account #{user_name} is already existing"
    end

    Rake::Task["db:create_couchdb_yml"].invoke(user_name, password)
  end

  desc "Create/Copy couchdb.yml from couchdb.yml.example"
  task :create_couchdb_yml, :user_name, :password  do |t, args|
    default_env = ENV['RAILS_ENV'] || "development"
    environments = ["development", "test", "assets", "cucumber", "production", "uat", "standalone", "android", default_env].uniq
    user_name = ENV['couchdb_user_name'] || args[:user_name] || ""
    password = ENV['couchdb_password'] || args[:password] || ""

    default_config = {
      "host" => "localhost",
      "port" => 5984,
      "https_port" => 6984,
      "prefix" => "rapidftr",
      "username" => user_name,
      "password" => password,
      "ssl" => false
    }

    couchdb_config = {}
    environments.each do |env|
      couchdb_config[env] = default_config.merge("suffix" => "#{env}")
    end

    File.write File.join(Rails.root, 'config', 'couchdb.yml'), couchdb_config.to_yaml
  end

  desc "Drop all databases"
  task :delete => :environment do
    puts "Deleting all databases..."
    CouchSettings.instance.databases.each(&:delete!)
  end

end
