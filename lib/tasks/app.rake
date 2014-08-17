namespace :app do

  desc "Drop and recreate all databases, the solr index, and restart the app if you're running with passenger."
  task :reset => %w(app:confirm_data_loss db:delete db:seed db:migrate sunspot:reindex)

  task :confirm_data_loss => :environment do
    require 'readline'
    unless (input = Readline.readline("You will lose all data in Rails.env '#{Rails.env}'. Are you sure you wish to continue? (y/n) ")) == 'y'
      puts "Stopping because you entered '#{input}'."
      exit 1
    end
  end

end
