namespace :passenger do
  task :restart do
    sh "touch tmp/restart.txt"
  end
end
