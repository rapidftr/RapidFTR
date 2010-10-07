namespace :ci do
  
  task :build => %w( clean install_bundler_gems) do
    Rake::Task["sunspot:stop"].invoke
    Rake::Task["sunspot:start"].invoke
    Rake::Task["default"].invoke
  end
  
  task :clean do
    rm_f "rerun.txt"
  end
  
  task :install_bundler_gems do
    sh "bundle install"
  end
  
end
