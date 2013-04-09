# RFC2822 - Time formatting - is broken in Rack 1.2.x
#   Those versions of rack use Time.strftime("... %T ...")
#   %T is a shorthand for %H:%M:%S
#   But this %T shorthand is not featured in ruby 1.8.7

module Rack
  module Utils
    def rfc2822(time)
      time.rfc2822
    end
    module_function :rfc2822
  end
end
