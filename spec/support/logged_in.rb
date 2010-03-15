module LoggedIn
  Spec::Runner.configure do |config|
    config.before(:each) do
      @controller.stub!(:check_authentication)
    end
  end
end
