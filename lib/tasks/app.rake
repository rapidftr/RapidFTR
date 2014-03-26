namespace :app do
  task :assets_precompile do
    Rake::Task['assets:precompile'].invoke
  end

  desc "Start the server in development mode with Sunspot running"
  task :run => %w( sunspot:clean_start scheduler:restart app:assets_precompile) do
    sh 'bundle exec rails server'
  end

  desc "Start the thin server in development mode with Sunspot running"
  task :run_standalone => %w( sunspot:clean_start scheduler:restart app:assets_precompile) do
    sh "bundle exec thin start --daemonize --chdir #{Rails.root}"
  end

  desc "Stop the thin server"
  task :stop_standalone => %w( scheduler:stop sunspot:stop ) do
    pid_file = 'tmp/pids/server.pid'
    pid = File.read(pid_file).to_i
    Process.kill 9, pid
    File.delete pid_file
  end

  desc "Drop and recreate all databases, the solr index, and restart the app if you're running with passenger."
  task :reset do
    Rake::Task['app:confirm_data_loss'].invoke
    Rake::Task['db:delete'].invoke
    #Rake::Task['couchdb:delete'].invoke("migration")
    #Rake::Task['couchdb:create'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['sunspot:clean_start'].invoke
    Rake::Task['passenger:restart'].invoke
  end

  task :confirm_data_loss => :environment do
    require 'readline'
    unless (input = Readline.readline("You will lose all data in Rails.env '#{Rails.env}'. Are you sure you wish to continue? (y/n) ")) == 'y'
      puts "Stopping because you entered '#{input}'."
      exit 1
    end
  end
end
