module LoggedIn
  Spec::Runner.configure do |config|
    config.before(:each) do
      fake_user = User.new(:user_name => 'some_user', :full_name => 'Fake User')
      @controller.stub!(:check_authentication).and_return(Session.for_user(fake_user))
    end
  end
end
