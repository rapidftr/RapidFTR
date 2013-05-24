namespace :app do

  desc "Create nginx/passenger configuration for deployment"
  task :setup_nginx do
    template "nginx_site.erb", File.join(fetch(:nginx_site_conf), "#{rails_env}_#{http_port}.conf")
  end

  desc "Restart passenger"
  task :restart do
    run_with_path_env "touch #{File.join('tmp', 'restart.txt')}"
  end

  desc "Create releases and log folder"
  task :create_release_dir, :except => { :no_release => true } do
    run "mkdir -p #{fetch :releases_path}"
    run "mkdir -p #{fetch :shared_path}/log"
  end

  desc "Create application configuration files"
  task :setup_application do
    template "rails_env.erb", File.join(current_path, "config", "environments", "#{rails_env}.rb")
    template "couch_config.erb", File.join(current_path, "config", "couchdb.yml")
  end

  desc "Create release version files"
  task :setup_revision do
    template "version.erb", File.join(current_path, "public", "version.txt")
  end

  desc "Migrate database"
  task :migrate_db do
    run_with_path_env "bundle exec rake couchdb:create db:seed db:migrate"
  end

  desc "Precompile assets"
  task :assets_precompile do
    run_with_path_env "bundle exec rake app:assets_precompile"
  end

  desc "Clean Start Solr"
  task :start_solr do
    run_with_path_env "bundle exec rake sunspot:restart"
  end

  desc "Start Scheduler Task"
  task :start_scheduler do
    run_with_path_env "bundle exec rake scheduler:restart" unless fetch(:app_version) =~ /0\.9\.0/
  end

end
