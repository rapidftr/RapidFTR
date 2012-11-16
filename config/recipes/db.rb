namespace :db do

  desc "Migrate database"
  task :migrate do
    run_rake "couchdb:create db:seed db:migrate"
  end

end
