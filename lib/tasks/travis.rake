namespace :travis do

  desc "Runs either RSpec or Cucumber based on RAILS_ENV"
  task :run do
    Rake::Task['spec'].invoke if Rails.env.test?
    Rake::Task['cucumber'].invoke if Rails.env.cucumber?
  end

end
