module FakeLogin
  def fake_login session = Session.new(:user => User.new(:user_name => 'fakeuser'))
    @controller.stub!(:app_session).and_return(session)
  end
  
  def fake_admin_login
    fake_login Session.new(:user => User.new(:user_name => 'fakeadmin', :user_type => 'Administrator'))
  end
end
