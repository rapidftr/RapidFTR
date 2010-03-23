namespace :ci do
  
  task :build => %w( clean install_test_gems install_cucumber_gems default)
  
  task :clean do
    sh "rm rerun.txt"
  end
  
  task :install_test_gems do
    sh "rake -t gems:install RAILS_ENV=test"
  end
  
  task :install_cucumber_gems do
    sh "rake -t gems:install RAILS_ENV=cucumber"
  end
  
end
