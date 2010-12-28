require(File.join(File.dirname(__FILE__),'..', '..', 'config', 'environment'))

namespace :sunspot do
  desc "start sunspot solr"
  task :start do
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
    end

  end
end