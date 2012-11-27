if Rails.env.cucumber? and Net::BufferedIO.respond_to? :old_rbuf_fill
  class Net::BufferedIO
    alias_method :rbuf_fill, :old_rbuf_fill
  end
end
