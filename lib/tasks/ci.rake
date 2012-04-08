namespace :ci do

  task :build => %w( sunspot:stop sunspot:start spec jasmine:ci cucumber:all )

  task :default => :build

  task :reload_nginx_conf do
    require 'pathname'
    nginx = ENV['NGINX_EXECUTABLE'] || '/opt/nginx/sbin/nginx'
    log_dir = Pathname.new(__FILE__).dirname.join('../../log')
    mkdir_p log_dir
    %w(insecure_access.log secure_access.log).each {|log_file| touch log_dir.join(log_file) }
    sh "sudo #{nginx} -t" # to make sure it's valid before messing things up.
    sh "sudo #{nginx} -s reload"
  end
end
