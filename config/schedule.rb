# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, File.join(Rails.root, "log/cron_log.log")

# every :monday, :at => "00:01 am" do
# 	runner "ReportsGenerator.generate"
# end

r = ReportsGenerasdtor.new

every 10.seconds do
	runner "ReportsGenerator.generate"	
end