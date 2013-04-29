RapidFTR::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # http://jira.codehaus.org/browse/JRUBY-6511
  class Net::BufferedIO
    def rbuf_fill
      if IO.select [@io], [@io], nil, @read_timeout
        @io.sysread BUFSIZE, @rbuf
      else
        raise Timeout::Error.new 'execution expired'
      end
    end
  end
end
