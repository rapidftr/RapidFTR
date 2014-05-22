# Setup RapidFTR from git source

node.rapidftr.release_env_dir  = File.join node.rapidftr.release_base_dir, node.rapidftr.host
node.rapidftr.release_dir = File.join node.rapidftr.release_env_dir, 'current'
node.rapidftr.cert_dir = File.join node.rapidftr.nginx_cert_conf, node.rapidftr.host

group 'www-data' do
  action :modify
end

user 'www-data' do
  action :modify
  gid 'www-data'
end

[ "", "shared", "shared/log", "shared/pids", "shared/gems" ].each do |dir|
  directory "rapidftr-shared-#{dir}" do
    owner 'www-data'
    group 'www-data'
    mode '0755'
    path File.join(node.rapidftr.release_env_dir, dir)
    recursive true
  end
end

deploy_revision "rapidftr-git" do
  repo node.rapidftr.repository
  revision node.rapidftr.revision
  deploy_to node.rapidftr.release_env_dir
  keep_releases 1
  user "www-data"
  group "www-data"
  shallow_clone true
  symlinks "pids" => "tmp/pids", "log" => "log", "gems" => "vendor/bundle"
  environment "RAILS_ENV" => node.rapidftr.rails_env
end

template "rails-environment" do
  path File.join(node.rapidftr.release_dir, 'config', 'environments', node.rapidftr.rails_env + '.rb')
  owner "www-data"
  group "www-data"
  mode 0644
  variables node.rapidftr.to_hash
end

execute "bundle-install" do
  command "bundle install --deployment"
  cwd node.rapidftr.release_dir
  environment "RAILS_ENV" => node.rapidftr.rails_env
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

execute "rake-couchdb-config" do
  command "bundle exec rake 'db:create_couchdb_yml[#{node.rapidftr.couchdb_username}, #{node.rapidftr.couchdb_password}]'"
  environment "RAILS_ENV" => node.rapidftr.rails_env
  cwd node.rapidftr.release_dir
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

execute "rake-couchdb-migrate" do
  command "bundle exec rake couchdb:create db:seed db:migrate"
  environment "RAILS_ENV" => node.rapidftr.rails_env
  cwd node.rapidftr.release_dir
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

execute "rake-asset-precompile" do
  command "bundle exec rake assets:clean assets:precompile"
  environment "RAILS_ENV" => node.rapidftr.rails_env
  cwd node.rapidftr.release_dir
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

execute "rake-scheduler-restart" do
  command "bundle exec rake scheduler:restart"
  environment "RAILS_ENV" => node.rapidftr.rails_env
  cwd node.rapidftr.release_dir
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

execute "rake-sunspot-restart" do
  command "bundle exec rake sunspot:clean_start"
  environment "RAILS_ENV" => node.rapidftr.rails_env
  cwd node.rapidftr.release_dir
  path [ "/usr/local/rvm/bin" ]
  user "www-data"
  group "www-data"
end

template "nginx-site" do
  path File.join(node.rapidftr.nginx_site_conf, node.rapidftr.host + '.conf')
  owner "www-data"
  group "www-data"
  mode 0644
  variables node.rapidftr.to_hash
end

directory "nginx-ssl" do
  user "www-data"
  owner "www-data"
  mode 0440
  path node.rapidftr.cert_dir
  recursive true
end

cookbook_file "certificate.crt" do
  path File.join(node.rapidftr.cert_dir, "certificate.crt")
  owner "www-data"
  group "www-data"
  mode  0440
end

cookbook_file "certificate.key" do
  path File.join(node.rapidftr.cert_dir, "certificate.key")
  owner "www-data"
  group "www-data"
  mode 0440
end

file "nginx-default-localhost" do
  path File.join(node.rapidftr.nginx_site_conf, "default")
  action :delete
end

service "nginx" do
  action :restart
end
