require 'sunspot/rails/tasks'

class Sunspot::Rails::Server
  # Use the same PID file for different rails envs
  # Because now, in the same Solr, we can have multiple cores (one each for every rails env)
  def pid_file
    'sunspot.pid'
  end
end

namespace :sunspot do

  desc "wait for solr to be started"
  task :wait, [:timeout] => :environment do |t, args|
    require 'rsolr'

    connected = false
    seconds = args[:timeout] ? args[:timeout].to_i : 30
    puts "Waiting #{seconds} seconds for Solr to start..."

    timeout(seconds) do
      until connected
        begin
          connected = RSolr.connect(:url => Sunspot.config.solr.url).get "admin/ping"
        rescue
          sleep 1
        end
      end
    end

    fail "Solr is not responding" unless connected
  end

  Rake::Task["sunspot:reindex"].clear
  desc "re-index child records"
  task :reindex => :wait do
    puts 'Reindexing Solr...'
    Child.reindex!
  end

end
