FROM rapidftr/base:latest

ENV RAILS_ENV production
WORKDIR /rapidftr

# Install Gems
ADD Gemfile /rapidftr/Gemfile
ADD Gemfile.lock /rapidftr/Gemfile.lock
RUN bundle install --without development test cucumber --jobs 4 --path vendor/

# Copy codebase
COPY . /rapidftr/

# Precompile assets
RUN bundle exec rake assets:clean assets:precompile && \
    chown -R www-data:www-data /rapidftr

# Enable Services
RUN rm -f /etc/service/nginx/down && \
    rm -f /etc/service/solr/down && \
    rm -f /etc/service/scheduler/down

# Expose ports
EXPOSE 80
EXPOSE 443
