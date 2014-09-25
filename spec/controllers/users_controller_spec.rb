require 'spec_helper'

describe UsersController, :type => :controller do
  before do
    fake_admin_login
    fake_session = Session.new
    allow(fake_session).to receive(:admin?).with(no_args).and_return(true)
    allow(Session).to receive(:get).and_return(fake_session)
  end

  def mock_user(stubs = {})
    @mock_user ||= stub_model(User, stubs)
  end

  describe 'GET index' do
    before do
      @user = mock_user(:merge => {}, :user_name => 'someone')
    end

    it 'shows the page name' do
      get :index
      expect(assigns[:page_name]).to eq('Manage Users')
    end

    context 'filter and sort users' do
      before do
        @active_user_one = mock_user(:merge => {}, :user_name => 'active_user_one', :disabled => false, :full_name => 'XYZ')
        @active_user_two = mock_user(:merge => {}, :user_name => 'active_user_two', :disabled => false, :full_name => 'ABC')
        @inactive_user = mock_user(:merge => {}, :user_name => 'inactive_user', :disabled => true, :full_name => 'inactive_user')

      end
      it 'should filter active users and sort them by full_name by default' do
        expect(User).to receive(:view).with('by_full_name_filter_view', :startkey => ['active'], :endkey => ['active', {}]).and_return([@active_user_two, @active_user_one])
        get :index
        expect(assigns[:users]).to eq([@active_user_two, @active_user_one])
      end

      it 'should filter all users and sort them by full_name' do
        expect(User).to receive(:view).with('by_full_name_filter_view', :startkey => ['all'], :endkey => ['all', {}]).and_return([@active_user_two, @inactive_user, @active_user_one])
        get :index, :sort => 'full_name', :filter => 'all'
        expect(assigns[:users]).to eq([@active_user_two, @inactive_user, @active_user_one])
      end

      it 'should filter all users and sort them by user_name' do
        expect(User).to receive(:view).with('by_user_name_filter_view', :startkey => ['all'], :endkey => ['all', {}]).and_return([@active_user_one, @active_user_two, @inactive_user])
        get :index, :sort => 'user_name', :filter => 'all'
        expect(assigns[:users]).to eq([@active_user_one, @active_user_two, @inactive_user])
      end

      it 'should filter active users and sort them by full_name' do
        expect(User).to receive(:view).with('by_full_name_filter_view', :startkey => ['active'], :endkey => ['active', {}]).and_return([@active_user_two, @active_user_one])
        get :index, :sort => 'full_name', :filter => 'active'
        expect(assigns[:users]).to eq([@active_user_two, @active_user_one])
      end

      it 'should filter active users and sort them by user_name' do
        expect(User).to receive(:view).with('by_user_name_filter_view', :startkey => ['active'], :endkey => ['active', {}]).and_return([@active_user_one, @active_user_two])
        get :index, :sort => 'user_name', :filter => 'active'
        expect(assigns[:users]).to eq([@active_user_one, @active_user_two])
      end
    end

    it 'assigns users_details for backbone' do
      allow(User).to receive(:view).and_return([@user])
      get :index
      users_details = assigns[:users_details]
      expect(users_details).not_to be_nil
      user_detail = users_details[0]
      expect(user_detail[:user_name]).to eq('someone')
      expect(user_detail[:user_url]).not_to be_blank
    end

    it 'should return error if user is not authorized' do
      fake_login
      stub_model User
      get :index
      expect(response).to be_forbidden
    end

    it 'should authorize index page for read only users' do
      user = User.new(:user_name => 'view_user')
      allow(user).to receive(:roles).and_return([Role.new(:permissions => [Permission::USERS[:view]])])
      fake_login user
      get :index
      expect(assigns(:access_error)).to be_nil
    end
  end

  describe 'GET show' do
    it 'assigns the requested user as @user' do
      mock_user = double(:user_name => 'fakeadmin')
      allow(User).to receive(:get).with('37').and_return(mock_user)
      get :show, :id => '37'
      expect(assigns[:user]).to equal(mock_user)
    end

    it 'should flash an error and go to listing page if the resource is not found' do
      allow(User).to receive(:get).with('invalid record').and_return(nil)
      get :show, :id => 'invalid record'
      expect(flash[:error]).to eq('User with the given id is not found')
      expect(response).to redirect_to(:action => :index)
    end

    it 'should show self user for non-admin' do
      session = fake_login
      get :show, :id => session.user.id
      expect(response).not_to be_forbidden
    end

    it 'should not show non-self user for non-admin' do
      fake_login
      mock_user = double(:user_name => 'some_random')
      allow(User).to receive(:get).with('37').and_return(mock_user)
      get :show, :id => '37'
      expect(response.status).to eq(403)
    end
  end

  describe 'GET new' do
    it 'assigns a new user as @user' do
      user = stub_model User
      allow(User).to receive(:new).and_return(user)
      get :new
      expect(assigns[:user]).to equal(user)
    end

    it 'should assign all the available roles as @roles' do
      roles = ['roles']
      allow(Role).to receive(:all).and_return(roles)
      get :new
      expect(assigns[:roles]).to eq(roles)
    end

    it 'should throw error if an user without authorization tries to access' do
      fake_login_as(Permission::USERS[:view])
      get :new
      expect(response.status).to eq(403)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested user as @user' do
      allow(Role).to receive(:all).and_return(['roles'])
      mock_user = stub_model(User, :user_name => 'Test Name', :full_name => 'Test')
      allow(User).to receive(:get).with('37').and_return(mock_user)
      get :edit, :id => '37'
      expect(assigns[:user]).to equal(mock_user)
      expect(assigns[:roles]).to eq(['roles'])
    end

    it 'should not allow editing a non-self user for users without access' do
      fake_login_as(Permission::USERS[:view])
      allow(User).to receive(:get).with('37').and_return(mock_user(:full_name => 'Test Name'))
      get :edit, :id => '37'
      expect(response).to be_forbidden
    end

    it 'should allow editing a non-self user for user having edit permission' do
      fake_login_as(Permission::USERS[:create_and_edit])
      mock_user = stub_model(User, :full_name => 'Test Name', :user_name => 'fakeuser')
      allow(User).to receive(:get).with('24').and_return(mock_user)
      get :edit, :id => '24'
      expect(response.status).not_to eq(403)
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested user' do
      expect(User).to receive(:get).with('37').and_return(mock_user)
      expect(mock_user).to receive(:destroy)
      delete :destroy, :id => '37'
    end

    it 'redirects to the users list' do
      allow(User).to receive(:get).and_return(mock_user(:destroy => true))
      delete :destroy, :id => '1'
      expect(response).to redirect_to(users_url)
    end

    it 'should not allow a destroy' do
      fake_login_as(Permission::USERS[:create_and_edit])
      allow(User).to receive(:get).and_return(mock_user(:destroy => true))
      delete :destroy, :id => '37'
      expect(response.status).to eq(403)
    end

    it 'should allow user deletion for relevant user role' do
      fake_login_as(Permission::USERS[:destroy])
      mock_user = stub_model User
      expect(User).to receive(:get).with('37').and_return(mock_user)
      expect(mock_user).to receive(:destroy).and_return(true)
      delete :destroy, :id => '37'
      expect(response.status).not_to eq(403)
    end
  end

  describe 'POST update' do
    context 'when not admin user' do
      it 'should not allow to edit admin specific fields' do
        fake_login
        mock_user = double(:user_name => 'User_name')
        allow(User).to receive(:get).with('24').and_return(mock_user)
        allow(controller).to receive(:current_user_name).and_return('test_user')
        allow(mock_user).to receive(:has_role_ids?).and_return(false)
        post :update, :id => '24', :user => {:user_type => 'Administrator'}
        expect(response.status).to eq(403)
      end
    end

    context 'disabled flag' do
      it 'should not allow to edit disable fields for non-disable users' do
        fake_login_as(Permission::USERS[:create_and_edit])
        user = stub_model User, :user_name => 'some name'
        params = {:id => '24', :user => {:disabled => true}}
        User.stub :get => user
        post :update, params
        expect(response).to be_forbidden
      end

      it 'should allow to edit disable fields for disable users' do
        fake_login_as(Permission::USERS[:disable])
        user = stub_model User, :user_name => 'some name'
        params = {:id => '24', :user => {:disabled => true}}
        User.stub :get => user
        allow(User).to receive(:find_by_user_name).with(user.user_name).and_return(user)
        post :update, params
        expect(response).not_to be_forbidden
      end

    end
    context 'create a user' do
      it 'should create admin user if the admin user type is specified' do
        fake_login_as(Permission::USERS[:create_and_edit])
        mock_user = User.new
        expect(User).to receive(:new).with('role_ids' => %w(abcd)).and_return(mock_user)
        expect(mock_user).to receive(:save).and_return(true)
        post :create, 'user' => {'role_ids' => %w(abcd)}
      end

      it 'should render new if the given user is invalid and assign user,roles' do
        mock_user = User.new
        allow(Role).to receive(:all).and_return('some roles')
        expect(User).to receive(:new).and_return(mock_user)
        expect(mock_user).to receive(:save).and_return(false)
        put :create, :user => {:role_ids => ['wxyz']}
        expect(response).to render_template :new
        expect(assigns[:user]).to eq(mock_user)
        expect(assigns[:roles]).to eq('some roles')
      end
    end
  end

  describe 'POST update unverified user' do
    it 'should set verify to true, if user is invalid' do
      allow(controller).to receive(:authorize!).and_return(true)
      expect(User).to receive(:get).with('unique_id').and_return(double('user', :update_attributes => false, :verified? => false))
      post :update, :id => 'unique_id', :user => {:verified => true}
      expect(controller.params[:verify]).to be true
    end

    it 'should update all the children of recently verified users' do
      mock_user = User.new(:user_name => 'user', :verified => false)
      allow(controller).to receive(:authorize!).and_return(true)
      child1 = double('child')
      child2 = double('child')
      allow(mock_user).to receive(:update_attributes).and_return(true)
      expect(User).to receive(:get).with('unique_id').and_return(mock_user)
      expect(child1).to receive(:verified=).with(true)
      expect(child1).to receive(:save)
      expect(child2).to receive(:verified=).with(true)
      expect(child2).to receive(:save)
      expect(Child).to receive(:by_created_by).with(:key => 'user').and_return([child1, child2])
      post :update, :id => 'unique_id', :user => {:verified => true}
    end

    it 'should call verify_children only for recently verified users' do
      mock_user = User.new(:user_name => 'user', :verified => true)
      allow(mock_user).to receive(:update_attributes).and_return(true)
      expect(User).to receive(:get).with('unique_id').and_return(mock_user)
      expect(Child).not_to receive(:by_created_by)
      post :update, :id => 'unique_id', :user => {:verified => true}
    end
  end

  describe 'GET change_password' do
    before :each do
      @user = User.new(:user_name => 'fakeuser')
      @mock_change_form = double
      fake_login @user
      @mock_params = {'mock' => 'mock'}
      allow(Forms::ChangePasswordForm).to receive(:new).with(@mock_params).and_return(@mock_change_form)
    end

    it 'should show update password form' do
      allow(Forms::ChangePasswordForm).to receive(:new).with(:user => @user).and_return(@mock_change_form)
      get :change_password
      expect(assigns[:change_password_request]).to eq(@mock_change_form)
      expect(response).to render_template :change_password
    end

    it 'should make password request from parameters' do
      expect(@mock_change_form).to receive(:user=).with(@user).and_return(nil)
      expect(@mock_change_form).to receive(:execute).and_return(true)

      post :update_password, :forms_change_password_form => @mock_params
      expect(flash[:notice]).to eq('Password changed successfully')
      expect(response).to redirect_to :action => :show, :id => @user.id
    end

    it 'should show error when any of the fields is wrong' do
      expect(@mock_change_form).to receive(:user=).with(@user).and_return(nil)
      expect(@mock_change_form).to receive(:execute).and_return(false)

      post :update_password, :forms_change_password_form => @mock_params
      expect(response).to render_template :change_password
    end
  end

  describe 'register_unverified' do
    it 'should set verified status to false' do
      expect(User).to receive(:find_by_user_name).twice.and_return(nil)
      expect(User).to receive(:new).with('user_name' => 'salvador', 'verified' => false, 'password' => 'password', 'password_confirmation' => 'password').and_return(user = 'some_user')
      expect(user).to receive :save!

      post :register_unverified, :format => :json, :user => {:user_name => 'salvador', 'unauthenticated_password' => 'password'}

      expect(response).to be_ok
    end

    it 'should not attempt to create a user if already exists' do
      expect(User).to receive(:find_by_user_name).and_return('something that is not nil')
      expect(User).not_to receive(:new)

      post :register_unverified, :format => :json, :user => {:user_name => 'salvador', 'unauthenticated_password' => 'password'}
      expect(response).to be_ok
    end
  end

  describe 'index unverified users' do
    it 'should list all unverfied users' do
      unverified_users = [double('user')]
      expect(User).to receive(:all_unverified).and_return(unverified_users)
      get :unverified
      expect(assigns[:users]).to eq(unverified_users)
      expect(flash[:verify]).to eq('Please select a role before verifying the user')
    end

    it 'should show page name' do
      get :unverified
      expect(assigns[:page_name]).to eq('Unverified Users')
    end
  end

end
