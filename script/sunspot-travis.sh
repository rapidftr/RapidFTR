#!/bin/sh

set +e

solr_responding() {
  port=$1
  curl -o /dev/null "http://localhost:$port/solr/admin/ping" > /dev/null 2>&1
}

wait_until_solr_responds() {
  port=$1
  while ! solr_responding $1; do
    /bin/echo -n "."
    sleep 1
  done
}

/bin/echo -n "Starting Solr on port 8983 for specs..."
if [ -f sunspot-solr.pid ]; then bundle exec sunspot-solr stop || true; fi

bundle exec sunspot-solr start -p 8983 -d /tmp/solr
wait_until_solr_responds 8983
/bin/echo "done."
