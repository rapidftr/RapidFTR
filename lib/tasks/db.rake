require 'restclient'
require 'fileutils'
require 'erb'
require 'readline'

namespace :db do
  desc "Seed with data (task manually created during the 3.0 upgrade, as it went missing)"
  task :seed => :environment do
    load(Rails.root.join("db", "seeds.rb"))
  end

  task :migrate => :environment do
    migration_db_name = [COUCHDB_CONFIG[:db_prefix], "migration", COUCHDB_CONFIG[:db_suffix]].join
    db = COUCHDB_SERVER.database!(migration_db_name)
    migration_ids = db.documents["rows"].select{|row| !row["id"].include?("_design")}.map{|row| row["id"]}
    migration_names = migration_ids.map{|id| db.get(id)[:name]}

    migrations_dir = "db/migration"
    Dir.new(Rails.root.join(migrations_dir)).entries.select { |file| file.ends_with? ".rb" }.sort.each do |file|
      if migration_names.include?(file)
        puts "skipping migration: #{file} - already applied"
      else
        puts "Applying migration: #{file}"
        load(Rails.root.join(migrations_dir, file))
        db.save_doc({:name => file})
      end
    end
  end

  desc "Create system administrator for couchdb. This is needed only if you are interested to test out replications"
  task :create_couch_sysadmin, :user_name, :password do |t, args|
    puts "
      **************************************************************
          Welcome to RapidFTR couchdb system administrator setup
      **************************************************************
    "

    url       = "http://localhost:5984"
    user_name = args[:user_name] || get("Enter username for CouchDB: ")
    password  = args[:password]  || get("Enter password for CouchDB: ")

    begin
      RestClient.post "#{url}/_session", "name=#{user_name}&password=#{password}", {:content_type => 'application/x-www-form-urlencoded'}
      puts "Administrator account #{user_name} is already existing and verified"
    rescue RestClient::Request::Unauthorized
      full_host = "#{url}/_config/admins/#{user_name}"
      RestClient.put full_host, "\""+password+"\"", {:content_type => :json}
      puts "Administrator account #{user_name} has been created"
    end

    Rake::Task["db:create_couchdb_yml"].invoke(user_name, password)
  end

  desc "Create/Copy couchdb.yml from cocuhdb.yml.example"
  task :create_couchdb_yml, :user_name, :password  do |t, args|
    default_env = ENV['RAILS_ENV'] || "development"
    environments = ["development", "test", "cucumber", "production", "uat", "standalone", "android", default_env].uniq
    user_name = ENV['couchdb_user_name'] || args[:user_name] || ""
    password = ENV['couchdb_password'] || args[:password] || ""

    default_config = {
      "host" => "localhost",
      "port" => 5984,
      "https_port" => 6984,
      "database_prefix" => "rapidftr_",
      "username" => user_name,
      "password" => password,
      "ssl" => false
    }

    couchdb_config = {}
    environments.each do |env|
      couchdb_config[env] = default_config.merge("database_suffix" => "_#{env}")
    end

    write_file Rails.root.to_s+"/config/couchdb.yml", couchdb_config.to_yaml
  end
end

def write_file name, content
  puts "Writing #{name}..."
  File.open(name, 'w') do |file|
    file.write content
  end
end

def get prompt
  Readline.readline prompt
end

