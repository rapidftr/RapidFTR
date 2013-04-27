namespace :passenger do
  task :restart do
    FileUtils.mkdir_p "tmp"
    FileUtils.touch "tmp/restart.txt"
  end
end
