module FakeLogin
  def fake_login user = User.new(:user_name => 'fakeuser', :permissions => [ "limited" ])
    session = Session.new :user => user
  	session.save
    @controller.stub!(:app_session).and_return(session)
    User.stub!(:find_by_user_name).with(user.user_name).and_return(user)
    session
  end
  
  def fake_admin_login
    fake_login User.new(:user_name => 'fakeadmin', :permissions => [ "admin" ])
  end

  def fake_unlimited_login
    fake_login User.new(:user_name => 'fakeunlimited', :permissions => [ "unlimited" ])
  end

  def fake_limited_login
    fake_login User.new(:user_name => 'fakelimited', :permissions => [ "limited" ])
  end
end
