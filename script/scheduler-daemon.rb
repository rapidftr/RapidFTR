# Rufus Scheduler runs in a background thread
# This causes problems when run in a multi-threaded or fork-oriented app server like nginx
# http://stackoverflow.com/questions/7420154/rufus-scheduler-only-running-once-on-production/7420409#7420409

# This script runs the Rufus Scheduler in a separate process
# "Daemons" gem is used to track the running process, so that it can be stopped later
# If we don't use daemons gem, then the process can only be stopped by Ctrl+C in the command line, or by finding out the PID and killing it

# The actual scheduling code is a Rake task (lib/tasks/scheduler.rake) which is invoked from here
# We are using a rake task so that the entire Rails environment can be loaded before running the task

# Usage: bundle exec ruby script/scheduler-daemon.rb start|stop|status|restart|...

require 'daemons'
require 'rake'

ROOT = File.expand_path('../..', __FILE__)

daemon_options = {
  :multiple => false,
  :backtrace => true,
  :dir => File.join(ROOT, 'log'),
  :dir_mode => :normal,
  :log_dir => File.join(ROOT, 'log'),
  :log_output => true
}

Daemons.run_proc('rapidftr-scheduler', daemon_options) do
  load File.join(ROOT, 'Rakefile')
  Rake::Task["scheduler:start"].invoke
end
