#!/bin/bash

RAPIDFTR_INSTALLDIR=/usr/lib/rapidftr

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {start|stop|restart}"
  exit $E_BADARGS
fi

cd $RAPIDFTR_INSTALLDIR

export RAILS_ENV=production

case "$1" in
  start)
    bundle exec rake app:run_with_thin
    ;;
  stop)
    bundle exec rake app:stop_thin
    ;;
  restart)
    bundle exec rake app:stop_thin
    bundle exec rake app:run_with_thin
    ;;
  *)
  echo "Usage: $0 {start|stop|restart}"
  exit 1
  ;;
esac

exit 0