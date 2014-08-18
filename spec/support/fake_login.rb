module FakeLogin
  def fake_login(user = User.new(:user_name => 'fakeuser', :role_ids => ['abcd']))
    session = Session.new :user_name => user.user_name
    session.save

    allow(user).to receive(:id).and_return('1234') unless user.try(:id)
    allow(User).to receive(:get).with(user.id).and_return(user)

    allow(@controller).to receive(:current_session).and_return(session)
    @controller.session[:last_access_time] = Clock.now.rfc2822

    allow(Role).to receive(:get).with('abcd').and_return(Role.new(:name => 'default', :permissions => [Permission::CHILDREN[:register]]))
    allow(User).to receive(:find_by_user_name).with(user.user_name).and_return(user)
    session
  end

  def setup_session(user = User.new(:user_name => 'fakeuser', :role_ids => ['abcd']))
    session = Session.new :user_name => user.user_name
    session.save
    allow(@controller).to receive(:current_session).and_return(session)
    @controller.session[:last_access_time] = Clock.now.rfc2822
    session
  end

  def fake_admin_login
    user = User.new(:user_name => 'fakeadmin')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => Permission.all_permissions)])
    fake_login user
  end

  def fake_field_admin_login
    user = User.new(:user_name => 'fakefieldadmin')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:view_and_search],
                                                                         Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])])
    fake_login user
  end

  def fake_field_worker_login
    user = User.new(:user_name => 'fakefieldworker')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::CHILDREN[:register]])])
    fake_login user
  end

  def fake_login_as(permission = Permission.all_permissions)
    user = User.new(:user_name => 'fakelimited')
    allow(user).to receive(:roles).and_return([Role.new(:permissions => [permission].flatten)])
    fake_login user
  end
end
