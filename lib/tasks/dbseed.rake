namespace :db do
  desc "Seed with data (task manually created during the 3.0 upgrade, as it went missing)"
  task :seed => :environment do
     load(Rails.root.join("db", "seeds.rb"))
     Dir.new(Rails.root.join("db")).entries.select{|file| file.ends_with?"_updation.rb"}.each do |file|
      puts "Applying updation #{file}"
      load(Rails.root.join("db", file))
     end
  end
end

