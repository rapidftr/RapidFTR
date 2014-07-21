require 'sunspot/rails/tasks'

class Sunspot::Rails::Server
  # Use the same PID file for different rails envs
  # Because now, in the same Solr, we can have multiple cores (one each for every rails env)
  def pid_file
    'sunspot.pid'
  end
end

namespace :sunspot do

  Rake::Task["sunspot:reindex"].clear

  desc "re-index child records"
  task :reindex => :environment do
    puts 'Reindexing Solr...'
    Child.reindex!
  end

  # TODO: Need some extra tasks like :clean, :wait
end
