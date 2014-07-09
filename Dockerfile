FROM phusion/passenger-full:0.9.11

ENV HOME /root
CMD ["/sbin/my_init"]

# Provision
ADD docker/provision.sh /root/rapidftr.sh
RUN /root/rapidftr.sh

# Gems
ADD Gemfile /rapidftr/Gemfile
ADD Gemfile.lock /rapidftr/Gemfile.lock

WORKDIR /rapidftr
RUN bundle install --without development test cucumber --jobs 4 --path vendor/

# CouchDB
ADD docker/config/couchdb.ini /etc/couchdb/local.d/rapidftr.ini
ADD docker/runit/couchdb/ /etc/service/couchdb/
EXPOSE 5984

# RapidFTR
ENV RAILS_ENV production
COPY . /rapidftr/

# Nginx
ADD docker/config/nginx-site.conf /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down
EXPOSE 80

# Services
# ADD docker/runit/solr/ /etc/service/solr/
# ADD docker/runit/scheduler/ /etc/service/scheduler/

ADD docker/login.sh /etc/my_init.d/00_setup_rapidftr.sh
