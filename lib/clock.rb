
class Clock

  def self.now
    @time_now || Time.now
  end

  def self.fake_time_now=(time)
    @time_now = time
  end

  def self.reset!
    @time_now = nil
  end
end

