#!/bin/sh

cd /rapidftr
RAILS_ENV=production bundle exec rake scheduler:run
