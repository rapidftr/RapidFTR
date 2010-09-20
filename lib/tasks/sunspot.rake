require(File.join(File.dirname(__FILE__),'..', '..', 'config', 'environment'))


namespace :sunspot do
  task :start do
    FileUtils.rm_rf "tmp/sunspot_index" if File.exists? "tmp/sunspot_index"
    Dir.mkdir "tmp/sunspot_index"
    sh "sunspot-solr start -d tmp/sunspot_index"
    sleep 3
    Child.reindex!
  end
  
  task :stop do
    sh "sunspot-solr stop"
  end
end