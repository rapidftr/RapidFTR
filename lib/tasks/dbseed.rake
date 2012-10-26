namespace :db do
  desc "Seed with data (task manually created during the 3.0 upgrade, as it went missing)"
  task :seed => :environment do
     load(Rails.root.join("db", "seeds.rb"))
     migrations_dir = "db/migration"
     Dir.new(Rails.root.join(migrations_dir)).entries.select{|file| file.ends_with?".rb"}.sort.each do |file|
      puts "Applying migration: #{file}"
      load(Rails.root.join(migrations_dir, file))
     end
  end
end

