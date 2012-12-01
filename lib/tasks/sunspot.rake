namespace :sunspot do

  def exec_solr(command)
    require 'tmpdir'
    port    = ENV['SOLR_PORT'] || "8983"
    pid_dir = File.join Dir.tmpdir, "sunspot_#{port}"

    FileUtils.mkdir_p pid_dir
    sh "sunspot-solr #{command} -p #{port} --pid-dir #{pid_dir} -l WARNING"
  end

  desc "start solr"
  task :start => :environment do
    tmp_dir = File.join "tmp", "sunspot_index"
    FileUtils.rm_rf tmp_dir
    FileUtils.mkdir_p tmp_dir
    exec_solr "start -d #{tmp_dir}"
  end

  desc "wait for solr to start"
  task :wait, :timeout, :needs => :environment do |t, args|
    connected = false
    seconds = args[:timeout] ? args[:timeout].to_i : 30
    timeout(seconds) do
      until connected do
        begin
          RSolr.connect(:url => Sunspot.config.solr.url).connection.get "/admin/ping"
          connected = true
        rescue
          connected = false
        end
      end
    end

    raise "Solr is not responding" unless connected
  end

  desc "re-index child records"
  task :reindex => :environment do
    Child.reindex!
  end

  desc "stop solr"
  task :stop => :environment do
    begin
      exec_solr "stop"
    rescue
      puts "Stop failed"
    end
  end

  desc "restart solr"
  task :restart => %w( sunspot:stop sunspot:start )

  desc "ensure solr is cleanly started"
  task :clean_start => %w( sunspot:restart sunspot:wait sunspot:reindex )

end
