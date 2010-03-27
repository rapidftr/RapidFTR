namespace :passenger do
  task :restart do
    touch "tmp/restart.txt"
  end
end
