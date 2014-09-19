FROM phusion/passenger-ruby21:0.9.11

ENV HOME /root
ENV RAILS_ENV production
WORKDIR /rapidftr

# Set Entrypoint and CMD
ENTRYPOINT ["/sbin/my_init"]
CMD ["--"]

# Provision
ADD docker/bootstrap.sh /root/
RUN /root/bootstrap.sh

# Service scripts
ADD docker/runit/couchdb/ /etc/service/couchdb/
ADD docker/runit/solr/ /etc/service/solr/
ADD docker/runit/scheduler/ /etc/service/scheduler/

# Service configurations
ADD docker/config/couchdb.ini /etc/couchdb/local.d/rapidftr.ini
ADD docker/config/nginx-site.conf /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down

# Enable first boot script
ADD docker/boot/production.sh /etc/my_init.d/00_setup_production.sh

# Enable worker start script
ADD docker/boot/start_workers.sh /etc/my_init.d/01_start_workers.sh

# Volumes and Ports
EXPOSE 5984
EXPOSE 6984
EXPOSE 80
EXPOSE 443
EXPOSE 8983
VOLUME /data

# Install Gems
ADD Gemfile /rapidftr/
ADD Gemfile.lock /rapidftr/
RUN bundle install --without development test cucumber --jobs 4 --path vendor/ && \
    rm -Rf vendor/ruby/2.1.0/cache

# Copy codebase
ADD config.ru /rapidftr/
ADD Rakefile /rapidftr/
ADD LICENSE /rapidftr/
ADD script/ /rapidftr/script/
ADD vendor/ /rapidftr/vendor/
ADD solr/ /rapidftr/solr/
ADD docker/config/solr.xml /rapidftr/solr/solr.xml
ADD public/ /rapidftr/public/
ADD config/ /rapidftr/config/
ADD db/ /rapidftr/db/
ADD lib/ /rapidftr/lib/
ADD app/ /rapidftr/app/
ADD https://www.dropbox.com/sh/y9cjomps39deqb6/AAB2ieXvhcohg_4J0BC3j2GXa/Android/RapidFTR-dev.apk?dl=1 /rapidftr/public/RapidFTR.apk
