namespace :ci do
  
  task :build => %w( clean install_bundler_gems default)
  
  task :clean do
    rm_f "rerun.txt"
  end
  
  task :install_bundler_gems do
    sh "bundle install"
  end
  
end
