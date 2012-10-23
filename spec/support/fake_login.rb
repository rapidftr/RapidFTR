module FakeLogin
  def fake_login user = User.new(:user_name => 'fakeuser', :permissions => [ Permission::LIMITED ])
    session = Session.new :user_name => user.user_name
  	session.save
    @controller.stub!(:app_session).and_return(session)
    User.stub!(:find_by_user_name).with(user.user_name).and_return(user)
    session
  end

  def fake_admin_login
    user = User.new(:user_name => 'fakeadmin')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::ADMIN])])
    fake_login user
  end

  def fake_unlimited_login
    user = User.new(:user_name => 'fakeunlimited')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::ACCESS_ALL_DATA])])
    fake_login user
  end

  def fake_limited_login
    user = User.new(:user_name => 'fakelimited')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::LIMITED])])
    fake_login user
  end
end
