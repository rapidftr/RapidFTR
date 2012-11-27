if Rails.env.development? or Rails.env.test? or Rails.env.cucumber?
  class Net::BufferedIO
    alias_method :rbuf_fill, :old_rbuf_fill
  end
end
