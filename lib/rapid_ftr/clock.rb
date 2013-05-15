module RapidFTR
  module Clock
    def self.current_formatted_time
      ::Clock.now.getutc.strftime("%Y-%m-%d %H:%M:%SUTC")
    end
  end
end