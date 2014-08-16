# This loads Rails environment and then starts the Scheduler
# This rake task can be used for local development purposes
# But the correct way to start this in production environments is script/scheduler-daemon.rb

namespace :scheduler do
  def daemon(argv="status")
    require 'daemons'

    daemon_options = {
      :multiple => false,
      :backtrace => true,
      :dir => File.join(Rails.root, 'log'),
      :dir_mode => :normal,
      :log_dir => File.join(Rails.root, 'log'),
      :log_output => true,
      :ARGV => [argv].flatten
    }

    Daemons.run_proc('rapidftr-scheduler', daemon_options) do
      load File.join(Rails.root, 'Rakefile')
      Rake::Task["scheduler:run"].invoke
    end
  end

  desc "Start scheduler in background"
  task :start do
    daemon "start"
  end

  desc "Stop scheduler"
  task :stop do
    daemon "stop"
  end

  desc "Restart scheduler"
  task :restart do
    daemon "restart"
  end

  desc "Scheduler status"
  task :status do
    daemon "status"
  end

  desc "Run scheduler in foreground"
  task :run => :environment do
    require 'rufus/scheduler'
    logger = Rails.logger = Logger.new(STDOUT, Rails.logger.level)

    scheduler = Rufus::Scheduler.start_new

    Replication.schedule scheduler
    WeeklyReport.schedule scheduler
    CleansingTmpDir.schedule scheduler

    logger.info 'Rufus scheduler initialized'
    scheduler.join
  end
end
