namespace :sunspot do

  desc "Clean Start Solr"
  task :clean_start do
    run_rake "sunspot:clean_start"
  end

end