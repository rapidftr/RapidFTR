module FakeLogin
  def fake_login session = Session.new(:user => User.new(:user_name => 'fakeuser', :id =>'24'))
  	session.save
    @controller.stub!(:app_session).and_return(session)
    User.stub!(:find_by_user_name).and_return(session.user)
  end
  
  def fake_admin_login
    fake_login Session.new(:user => User.new(:user_name => 'fakeadmin', :user_type => 'Administrator'))
  end
end
