namespace :ci do

  task :build => %w( sunspot:stop sunspot:start spec jasmine:ci cucumber:all )

  task :default => :build
  
  task :reload_nginx_conf do
    nginx = ENV['NGINX_EXECUTABLE'] || '/opt/nginx/sbin/nginx'
    sh "sudo #{nginx} -t" # to make sure it's valid before messing things up.
    sh "sudo #{nginx} -s reload"
  end
end
