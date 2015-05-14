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
      # add the enable enquiries variable
      enable_enquiries = SystemVariable.find_by_name(SystemVariable::ENABLE_ENQUIRIES)
      if enable_enquiries.nil?
        SystemVariable.create :name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => true
      else
        enable_enquiries.value = 1
        enable_enquiries.save!
      end

      # add the score threshold variable
      score_threshold = SystemVariable.find_by_name(SystemVariable::SCORE_THRESHOLD)
      if score_threshold.nil?
        SystemVariable.create! :name => SystemVariable::SCORE_THRESHOLD, :type => 'number', :value => '0.00'
      end

      # add enquiries form if it doesn't exist
      form = Form.find_by_name(Enquiry::FORM_NAME)
      if form.nil?
        RapidFTR::EnquiriesFormSectionSetup.reset_form
      end
    end

    desc 'Disable the enquiries feature'
    task :disable => :environment do
      enable_enquiries = SystemVariable.find_by_name(SystemVariable::ENABLE_ENQUIRIES)
      if enable_enquiries.nil?
        SystemVariable.create :name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => '0'
      else
        enable_enquiries.value = 0
        enable_enquiries.save!
      end

      # remove the score threshold variable
      score_threshold = SystemVariable.find_by_name(SystemVariable::SCORE_THRESHOLD)
      unless score_threshold.nil?
        score_threshold.destroy
      end

      # remove enquiry form
      form = Form.find_by_name(Enquiry::FORM_NAME)
      unless form.nil?
        form.destroy
      end
    end
  end

end
