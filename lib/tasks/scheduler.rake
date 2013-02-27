# This loads Rails environment and then starts the Scheduler
# This rake task can be used for local development purposes
# But the correct way to start this in production environments is script/scheduler-daemon.rb

namespace :scheduler do
  desc "Start Rufus Scheduler"
  task :start => :environment do
    require 'rufus/scheduler'
    logger = Rails.logger = Logger.new(STDOUT, Rails.logger.level)

    scheduler = Rufus::Scheduler.start_new

    Replication.schedule scheduler
    WeeklyReport.schedule scheduler

    logger.info 'Rufus scheduler initialized'
    scheduler.join
  end
end
