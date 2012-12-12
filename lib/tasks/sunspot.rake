require 'tmpdir'

namespace :sunspot do

  def solr_server
    server = Sunspot::Solr::Server.new
    server.port = ENV['SOLR_PORT'] || '8983'
    server.pid_file = "sunspot_#{server.port}.pid"
    server.pid_dir = Dir.tmpdir
    server
  end

  desc "start solr"
  task :start => :environment do
    puts 'Starting Solr...'
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
    puts 'Waiting for Solr to start...'
    connected = false
    seconds = args[:timeout] ? args[:timeout].to_i : 30
    timeout(seconds) do
      until connected do
        begin
          connected = RSolr.connect(:url => Sunspot.config.solr.url).get "admin/ping"
        rescue => e; end
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
  task :restart => %w( sunspot:solr:stop sunspot:solr:start )

  desc "ensure solr is cleanly started"
  task :clean_start => %w( sunspot:restart sunspot:reindex )

end
