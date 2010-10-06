require(File.join(File.dirname(__FILE__),'..','..','config','environment'))

namespace :app do
  desc "Start the server in development mode with Sunspot running"
  task :run do
    Rake::Task['sunspot:stop'].invoke
    Rake::Task['sunspot:start'].invoke
    sh 'script/server'    
  end
end
