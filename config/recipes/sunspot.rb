namespace :sunspot do

  desc "Start Solr"
  task :start do
    run_rake "sunspot:start"
  end

  desc "Stop Solr"
  task :stop do
    run_rake "sunspot:stop"
  end

  desc "Restart Solr"
  task :restart do
    run_rake "sunspot:restart"
  end

end