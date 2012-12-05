module FakeLogin
  def fake_login user = User.new(:user_name => 'fakeuser', :role_ids => ["abcd"])
    session = Session.new :user_name => user.user_name
  	session.save

    user.stub(:id => 1234) unless user.try(:id)
    User.stub!(:get).with(user.id).and_return(user)

    @controller.stub!(:app_session).and_return(session)
    Role.stub!(:get).with("abcd").and_return(Role.new(:name => "default", :permissions => [Permission::CHILDREN[:register]]))
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
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:view_and_search],
                                                             Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])])
    fake_login user
  end

  def fake_field_worker_login
    user = User.new(:user_name => 'fakefieldworker')
    user.stub!(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:register]])])
    fake_login user
  end

  def fake_login_as(permission = Permission::ADMIN[:admin])
    user = User.new(:user_name => 'fakelimited')
    user.stub!(:roles).and_return([Role.new(:permissions => [permission])])
    fake_login user
  end

end
