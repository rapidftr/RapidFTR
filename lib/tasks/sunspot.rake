namespace :sunspot do
  desc "start sunspot solr"
  task :start => :environment do
    FileUtils.rm_rf "tmp/sunspot_index" if File.exists? "tmp/sunspot_index"
    FileUtils.mkdir_p "tmp/sunspot_index"
    sh "sunspot-solr start -d tmp/sunspot_index -p #{ENV['SOLR_PORT'] || "8983"}"
    sleep 10
    
    Child.reindex!
  end

  desc "stop sunspot solr"
  task :stop do
    begin
      sh "sunspot-solr stop"
    rescue
      puts "Stop failed."
    end
  end

  desc "restart sunspot solr"
  task :restart => %w( sunspot:stop sunspot:start )
end
