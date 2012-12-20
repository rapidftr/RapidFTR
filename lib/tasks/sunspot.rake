require 'tmpdir'

namespace :sunspot do

  def solr_server
    server = Sunspot::Solr::Server.new
    server.port = ENV['SOLR_PORT'] || '8983'
    server.pid_file = "sunspot_#{server.port}.pid"
    server.pid_dir = ENV['SOLR_PID_LOCATION'] || Dir.tmpdir
    server
  end

  def copy_solr_config
    puts "Copying config"
    solr_config_location = "#{Gem.loaded_specs['sunspot_solr'].full_gem_path}/solr/solr/conf/solrconfig.xml"
    FileUtils.cp( "#{Rails.root}/config/solrconfig.xml" ,solr_config_location)
    puts "Done: Copying config"
  end

  desc "start solr"
  task :start => :environment do
    puts 'Starting Solr...'
    copy_solr_config
    solr_server.start
  end

  desc "stop solr"
  task :stop => :environment do
    begin
      puts 'Stopping Solr...'
      solr_server.stop
    rescue => e; end
  end

  desc "wait for solr to start"
  task :wait, :timeout, :needs => :environment do |t, args|
    connected = false
    seconds = args[:timeout] ? args[:timeout].to_i : 60
    timeout(seconds) do
      until connected do
        begin
          puts 'Waiting for Solr to start...'
          connected = RSolr.connect(:url => Sunspot.config.solr.url).get "admin/ping"
        rescue => e
          sleep 1
        end
      end
    end

    raise "Solr is not responding" unless connected
  end

  desc "re-index child records"
  task :reindex => :wait do
    puts 'Reindexing Solr...'
    Child.reindex!
  end

  desc "restart solr"
  task :restart => %w( sunspot:stop sunspot:start )

  desc "ensure solr is cleanly started"
  task :clean_start => %w( sunspot:restart sunspot:reindex )

end
