#!/bin/sh

echo "Starting Scheduler in $RAILS_ENV mode..."
cd /rapidftr
bundle exec rake scheduler:run
