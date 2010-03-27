namespace :passenger do
  task :restart do
    sh "pwd"
    sh "ls -lA"
    sh "touch tmp/restart.txt"
  end
end
