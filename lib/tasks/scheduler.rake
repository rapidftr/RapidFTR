namespace :scheduler do
  desc "Start Rufus Scheduler"
  task :start => :environment do
    require 'rufus/scheduler'
    logger = Rails.logger = Logger.new(STDOUT, Rails.logger.level)

    scheduler = Rufus::Scheduler.start_new

    Replication.schedule scheduler
    ReportsGenerator.schedule scheduler

    logger.info 'Rufus scheduler initialized'
    scheduler.join
  end
end
