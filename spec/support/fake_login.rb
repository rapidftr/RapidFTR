module FakeLogin
  def fake_login user = User.new(:user_name => 'fakeuser', :role_names => ["default"])
    session = Session.new :user_name => user.user_name
  	session.save
    @controller.stub!(:app_session).and_return(session)
    Role.stub!(:by_name).with(:key => "default").and_return(Role.new(:name => "default", :permissions => [Permission::CHILDREN[:register]]))
    User.stub!(:find_by_user_name).with(user.user_name).and_return(user)
    session
  end

  def fake_admin_login
    user = User.new(:user_name => 'fakeadmin')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::ADMIN[:admin]])])
    fake_login user
  end

  def fake_field_admin_login
    user = User.new(:user_name => 'fakefieldadmin')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:access_all_data]])])
    fake_login user
  end

  def fake_field_worker_login
    user = User.new(:user_name => 'fakefieldworker')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:register]])])
    fake_login user
  end
end
