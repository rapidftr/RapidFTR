FROM phusion/passenger-full:0.9.11

ENV HOME /root
ENV RAILS_ENV production
WORKDIR /rapidftr

# Set Entrypoint and CMD
ENTRYPOINT ["/sbin/my_init"]
CMD ["--"]

# Provision
ADD docker/bootstrap.sh /root/
RUN /root/bootstrap.sh

# CouchDB
ADD docker/config/couchdb.ini /etc/couchdb/local.d/rapidftr.ini
ADD docker/runit/couchdb/ /etc/service/couchdb/
EXPOSE 5984
EXPOSE 6984

# Nginx
ADD docker/config/nginx-site.conf /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down
EXPOSE 80
EXPOSE 443

# Services
ADD docker/runit/solr/ /etc/service/solr/
ADD docker/runit/scheduler/ /etc/service/scheduler/
EXPOSE 8983

# Enable first boot script
ADD docker/boot/production.sh /etc/my_init.d/00_setup_production.sh

# Install Gems
ADD Gemfile /rapidftr/
ADD Gemfile.lock /rapidftr/
RUN bundle install --without development test cucumber --jobs 4 --path vendor/

# Copy codebase
ADD config.ru /rapidftr/
ADD Rakefile /rapidftr/
ADD LICENSE /rapidftr/
ADD script/ /rapidftr/script/
ADD vendor/ /rapidftr/vendor/
ADD public/ /rapidftr/public/
ADD config/ /rapidftr/config/
ADD db/ /rapidftr/db/
ADD lib/ /rapidftr/lib/
ADD app/ /rapidftr/app/
ADD solr/ /rapidftr/solr/
