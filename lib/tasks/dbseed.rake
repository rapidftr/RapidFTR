namespace :db do
  desc "Seed with data (task manually created during the 3.0 upgrade, as it went missing)"
  task :seed => :environment do
     load(Rails.root.join("db", "seeds.rb"))
  end
end

