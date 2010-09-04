namespace :db do
  desc "Recreate suggested fields"
   task :seed_suggested_fields => :environment do
    seed_file = File.join(Rails.root, 'db', 'seed_suggested_fields.rb')
    load(seed_file)
  end
end