namespace :passenger do
  task :restart do
    mkdir "tmp"
    touch "tmp/restart.txt"
  end
end
