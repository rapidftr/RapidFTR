namespace :passenger do
  task :restart do
    mkdir_p "tmp"
    touch "tmp/restart.txt"
  end
end
