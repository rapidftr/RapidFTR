namespace :app do
  desc "Pre compiles the static assets and creates assets folder with common js and common css."
  task :assets_precompile do
    require 'jammit'
    Jammit.package!
  end

  desc "Start the server in development mode with Sunspot running"
  task :run => %w( db:migrate sunspot:stop sunspot:start app:assets_precompile) do
    sh 'bundle exec rails server'
  end

  desc "Drop and recreate all databases, the solr index, and restart the app if you're running with passenger."
  task :reset => %w( app:confirm_data_loss couchdb:delete couchdb:create db:seed db:migrate sunspot:restart passenger:restart )

  task :confirm_data_loss => :environment do
    require 'readline'
    unless (input = Readline.readline("You will lose all data in Rails.env '#{Rails.env}'. Are you sure you wish to continue? (y/n) ")) == 'y'
      puts "Stopping because you entered '#{input}'."
      exit 1
    end
  end
end
