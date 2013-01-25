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
    migrations_dir = "db/migration"
    Dir.new(Rails.root.join(migrations_dir)).entries.select { |file| file.ends_with? ".rb" }.sort.each do |file|
      puts "Applying migration: #{file}"
      load(Rails.root.join(migrations_dir, file))
    end
  end

  desc "Create system administrator for couchdb. This is needed only if you are interested to test out replications"
  task :create_couch_sysadmin => :environment do
    host = "http://127.0.0.1"
    port = "5984"
    env = ENV['RAILS_ENV'] || 'development'
    puts "
      **************************************************************

        Welcome to RapidFTR couchdb system administrator setup!

      **************************************************************
      RapidFTR uses couchdb _users table for couchdb master to master replication.
      If you don't want to try the replication feature please hit CTRL + C.

      Else go on...
    "
    is_admin_available = get "Does your couchdb have admin credentials(yes/no) "
    raise "Invalid value #{is_admin_available}. Needed one of yes/no" unless %w[yes no].include?(is_admin_available)
    if is_admin_available == "yes"
      user_name = get "Enter username of your couchdb "
      password = get "Enter password of your couchdb "
    else
      user_name = "rapidftr"
      password = "rapidftr"
    end

    puts "
        Assuming you are running your couchdb server at http://127.0.0.1:5984/.
        If you are not, please change this @ #{__FILE__ }
         "

    begin
      RestClient.post "#{host}:#{port}/_session", "name=#{user_name}&password=#{password}", {:content_type => 'application/x-www-form-urlencoded'}
    rescue RestClient::Request::Unauthorized
      full_host = "#{host}:#{port}/_config/admins/#{user_name}"
      RestClient.put full_host, "\""+password+"\"", {:content_type => :json}
    end

    couchdb_config = YAML::load(ERB.new(Rails.root.join("config", "couchdb.yml.example").read).result)
    couchdb_config[env].merge!({"username" => user_name, "password" => password})
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

