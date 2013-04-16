# SAMPLE USAGE:
# cap 
#   -S deploy_server=test.rapidftr.com 
#   -S deploy_user=admin                 # Password will be prompted by SSH, or you should be using SSH keys
#   -S server_name=test.rapidftr.com     # Can be left blank if we're using only port-based deployment without using virtual hosts
#   -S rails_env=android 
#   -S http_port=80 
#   -S https_port=443 
#   -S solr_port=8983 
#   -S couchdb_host=<couch-host>         # Can be left blank for localhost
#   -S couchdb_username=<couch-username> # Can be left blank if no authentication required
#   -S couchdb_password=<couch-password> # Can be left blank if no authentication required
#   -S nginx_site_conf=/opt/local/nginx/conf/sites.d # Path to nginx per-site configuration folder
#   -S branch=<commit-id (or) release1 (or) master>
# deploy

# To deploy a specific revision to any environment use
#   -S branch=<commit-sha>

# Use cap deploy:pending and cap deploy:pending:diff to find out the diff between the master and the current deployed revision in the server

require "bundler/capistrano"

def prompt_config(variable, description)
  value = exists?(variable) ? fetch(variable) : nil

  if value.to_s.empty? and $stdout.isatty
    value = Capistrano::CLI.ui.ask(description).strip
  end

  raise "#{description} not provided" if value.to_s.empty?
  set variable, value
end

prompt_config :deploy_server, "Deploy to Server"
prompt_config :deploy_user, "User Name"
prompt_config :rails_env, "RAILS_ENV"
prompt_config :http_port, "HTTP Port"
prompt_config :https_port, "HTTPS Port"
prompt_config :solr_port, "Solr Port"
prompt_config :nginx_site_conf, "Nginx Per-Site Configuration Folder"

set :application, "RapidFTR"
set :deploy_dir, "/srv/rapid_ftr_#{rails_env}"

server deploy_server, :web, :app, :db
default_run_options[:pty] = $stdout.isatty
set :user, deploy_user
set :deploy_to, deploy_dir

set :scm, :git
set :repository,  "git://github.com/rapidftr/RapidFTR.git"
set :deploy_via, :remote_cache
set :branch, fetch(:branch, "master")
set :keep_releases, 5
set :use_sudo, false

load 'config/recipes/base_tasks'
load 'config/recipes/app_tasks'

before 'deploy:update_code', 'app:create_release_dir'
after  'deploy:update', 'deploy:cleanup', 'app:setup_nginx', 'app:setup_application', 'app:setup_revision', 'app:migrate_db', 'app:start_solr', 'app:start_scheduler', 'app:restart'
