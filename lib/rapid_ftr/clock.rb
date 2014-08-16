module RapidFTR
  module Clock
    # TODO Use Timecop or something similar, this exists for freezing time in the tests
    def self.current_formatted_time
      ::Clock.now.getutc.strftime("%Y-%m-%d %H:%M:%SUTC")
    end
  end
end
