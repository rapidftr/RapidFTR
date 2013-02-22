require 'rubygems'
require 'rufus/scheduler'
include ReportsGenerator
	
reports_dir = File.join(Rails.root, "reports")
FileUtils.mkdir_p(reports_dir) unless File.exist? reports_dir

scheduler = Rufus::Scheduler.start_new

scheduler.cron '0 1 0 ? * MON' do # every monday at 00:01
  puts "generating report"
  ReportsGenerator.generate
end
