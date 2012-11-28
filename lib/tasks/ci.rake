namespace :ci do

  task :build => %w( couchdb:create sunspot:clean_start spec jasmine:ci cucumber:all )

  task :default => :build

  task :cheap_deploy do
    require 'pathname'
    deploy_dir = Pathname.new(ENV['DEPLOY_DIR']).expand_path
    safe_deploy_area = "/home/jorge/Code"
    raise "Won't deploy outside of #{safe_deploy_area}." unless deploy_dir.to_s.start_with? safe_deploy_area

    rm_rf deploy_dir
    cp_r '.', deploy_dir
    cd deploy_dir do
      sh "rake passenger:restart ci:reload_nginx_conf"
    end
  end

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
