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

  namespace :enquiries do
    desc 'Enable the enquiries feature'
    task :enable => :environment do
      enable_enquiries = SystemVariable.find_by_name('ENABLE_ENQUIRIES')
      if enable_enquiries.nil?
        SystemVariable.create :name => 'ENABLE_ENQUIRIES', :type => 'boolean', :value => true
      else
        enable_enquiries.value = 1
        enable_enquiries.save!
      end
    end

    desc 'Disable the enquiries feature'
    task :disable => :environment do
      enable_enquiries = SystemVariable.find_by_name('ENABLE_ENQUIRIES')
      unless enable_enquiries.nil?
        enable_enquiries.value = 0
        enable_enquiries.save!
      end
    end
  end

end
