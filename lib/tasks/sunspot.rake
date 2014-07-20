require 'sunspot/rails/tasks'

class Sunspot::Rails::Server
  # Use the same PID file for different rails envs
  # Because now, in the same Solr, we can have multiple cores (one each for every rails env)
  # TODO:
  #   [x] tmp/pids must survive deploys
  #   [ ] solr/solr.xml must be replaced for prod to avoid unnecessary cores
  #   [ ] solr/data must survive deploys
  #   [ ] Change Chef & Docker scripts
  def pid_file
    'sunspot.pid'
  end
end

namespace :sunspot do
  # Any extra tasks, like :wait, :reindex, etc
  # For now, :reindex is in app.rake, so nothing here for now
end
