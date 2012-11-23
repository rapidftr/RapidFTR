require "bundler/capistrano"

set :application, "RapidFTR"
set :deploy_env, ENV['RAILS_ENV']
set :deploy_domain, "#{deploy_env}.rapidftr.com"
set :deploy_dir, "/srv/rapid_ftr_#{deploy_env}"

raise "Rails env not specified" if deploy_env.nil? or deploy_env.empty?

server "li301-66.members.linode.com", :web, :app, :db
default_run_options[:pty] = true  # Must be set for the password prompt
set :user, "admin"  # The server's user for deploys
set :deploy_to, deploy_dir

set :scm, :git
set :repository,  "git://github.com/rapidftr/RapidFTR.git"
set :deploy_via, :remote_cache
set :branch, fetch(:branch, "master")
#to deploy a specific revision to any environment use
#RAILS_ENV=<env_name> cap -S branch=<commit-sha> deploy
#If you want to deploy the latest master use the command
#RAILS_ENV=<env_name> cap deploy

load 'config/recipes/base'
load 'config/recipes/deploy'
load 'config/recipes/db'
# load 'config/recipes/sunspot'

before 'deploy:update_code', 'deploy:create_release_dir'
after  'deploy:update', 'deploy:setup_application', 'deploy:setup_nginx', 'db:migrate'

#use RAILS_ENV=<env> cap deploy:pending and cap deploy:pending:diff to find out the diff between the master and the
#current deployed revision in the server.