namespace :deploy do

  desc "Create nginx/passenger configuration for deployment"
  task :setup_nginx do
    template "nginx_site.erb", "/opt/local/nginx/conf/sites.d/#{deploy_env}_#{deploy_port}.conf"
  end

  desc "Restart passenger"
  task :restart do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    sudo "/opt/local/nginx/sbin/nginx -s reload"
  end

  desc "Create releases and log folder"
  task :create_release_dir, :except => { :no_release => true } do
    run "mkdir -p #{fetch :releases_path}"
    run "mkdir -p #{fetch :shared_path}/log"
  end

  desc "Create application configuration files"
  task :setup_application do
    template "rails_env.erb", File.join(current_path, "config", "environments", "#{deploy_env}.rb")
    template "couch_config.erb", File.join(current_path, "config", "couchdb.yml")
  end

end
