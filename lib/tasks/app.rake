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
        SystemVariable.create :name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => true, :user_editable => false
      else
        enable_enquiries.value = true
        enable_enquiries.user_editable = false
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

      rapidreg_user = User.find_by_user_name('rapidreg')
      unless rapidreg_user.nil?
        rapidreg_user.destroy
      end

      rapidftr_user = User.find_by_user_name('rapidftr')
      unless rapidftr_user.nil?
        rapidftr_user.disabled = false
        rapidftr_user.save!
      end
    end

    desc 'Disable the enquiries feature'
    task :disable => :environment do
      enable_enquiries = SystemVariable.find_by_name(SystemVariable::ENABLE_ENQUIRIES)
      if enable_enquiries.nil?
        SystemVariable.create :name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => false, :user_editable => false
      else
        enable_enquiries.value = false
        enable_enquiries.user_editable = false
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

      system_admin = Role.find_by_name('System Admin')
      user = User.find_by_user_name('rapidreg')

      if user.nil? && !system_admin.nil?
        User.create!('user_name' => 'rapidreg',
                     'password' => 'rapidreg',
                     'password_confirmation' => 'rapidreg',
                     'full_name' => 'Rapidreg Administrator',
                     'email' => 'rapidreg@rapidreg.com',
                     'disabled' => 'false',
                     'organisation' => 'N/A',
                     'role_ids' => [system_admin.id])
      end

      rapidftr_user = User.find_by_user_name('rapidftr')
      unless rapidftr_user.nil?
        rapidftr_user.disabled = true
        rapidftr_user.save!
      end
    end
  end

end
