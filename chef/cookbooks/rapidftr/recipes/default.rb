# Setup RapidFTR from git source

node.rapidftr.src_dir  = File.join "/var/www/rapidftr", node.rapidftr.host
node.rapidftr.cert_dir = File.join node.rapidftr.nginx_cert_conf, node.rapidftr.host

group 'www-data' do
  action :modify
end

user 'www-data' do
  action :modify
  gid 'www-data'
end

directory 'rapidftr-dir' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  path node.rapidftr.src_dir
  recursive true
end

git "rapidftr-git" do
  user 'www-data'
  group 'www-data'
  repository node.rapidftr.repository
  revision node.rapidftr.revision
  depth 1
  destination node.rapidftr.src_dir
end

execute "bundle-install" do
  command "bundle install --deployment --without test cucumber development"
  cwd node.rapidftr.src_dir
  user 'www-data'
  group 'www-data'
  path [ "/usr/local/rvm/bin" ]
  environment "RAILS_ENV" => node.rapidftr.rails_env
end

execute "rake-couchdb-config" do
  command "bundle exec rake 'db:create_couchdb_yml[#{node.rapidftr.couchdb_username}, #{node.rapidftr.couchdb_password}]'"
  cwd node.rapidftr.src_dir
  user 'www-data'
  group 'www-data'
  path [ "/usr/local/rvm/bin" ]
  environment "RAILS_ENV" => node.rapidftr.rails_env
end

execute "rake-couchdb-migrate" do
  command "bundle exec rake couchdb:create db:seed db:migrate"
  cwd node.rapidftr.src_dir
  user 'www-data'
  group 'www-data'
  path [ "/usr/local/rvm/bin" ]
  environment "RAILS_ENV" => node.rapidftr.rails_env
end

execute "rake-asset-precompile" do
  command "bundle exec rake assets:precompile"
  cwd node.rapidftr.src_dir
  user 'www-data'
  group 'www-data'
  path [ "/usr/local/rvm/bin" ]
  environment "RAILS_ENV" => "assets"
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

template "rails-environment" do
  path File.join(node.rapidftr.src_dir, 'config', 'environments', node.rapidftr.rails_env + '.rb')
  owner "www-data"
  group "www-data"
  mode 0644
  variables node.rapidftr.to_hash
end

template "nginx-site" do
  path File.join(node.rapidftr.nginx_site_conf, node.rapidftr.host + '.conf')
  owner "www-data"
  group "www-data"
  mode 0644
  variables node.rapidftr.to_hash
end

file "nginx-default-localhost" do
  path File.join(node.rapidftr.nginx_site_conf, "default")
  action :delete
end

service "nginx" do
  action :restart
end
