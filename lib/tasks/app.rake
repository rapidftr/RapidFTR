namespace :app do

  desc "Drop and recreate all databases, the solr index, and restart the app if you're running with passenger."
  task :reset do
    Rake::Task['app:confirm_data_loss'].invoke
    Rake::Task['db:delete'].invoke
    #Rake::Task['couchdb:delete'].invoke("migration")
    #Rake::Task['couchdb:create'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['search:clean_start'].invoke
  end

  task :confirm_data_loss => :environment do
    require 'readline'
    unless (input = Readline.readline("You will lose all data in Rails.env '#{Rails.env}'. Are you sure you wish to continue? (y/n) ")) == 'y'
      puts "Stopping because you entered '#{input}'."
      exit 1
    end
  end

end
