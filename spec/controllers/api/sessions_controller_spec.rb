require 'spec_helper'

describe Api::SessionsController, :type => :controller do

  before :each do
    @admin_role = create :role
    @user = create :user, :password => 'test_password', :password_confirmation => 'test_password', :role_ids => [ @admin_role.name ]
    controller.stub :mobile_db_key => 'TEST_DB_KEY'
  end

  it 'should login' do
    allow(I18n).to receive(:default_locale).and_return("zz")
    post :login, :user_name => @user.user_name, :password => 'test_password', :imei => 'TEST_IMEI'

    expect(response).to be_success
    expect(JSON.parse(response.body)).to include({
                                                   "db_key" => 'TEST_DB_KEY',
                                                   "organisation" => @user.organisation,
                                                   "language" => "zz",
                                                   "verified" => @user.verified?
                                                 })
  end

  it 'should logout' do
    session = fake_login @user
    expect(session).to receive(:destroy).and_return(true)

    post :logout
    expect(response).to be_success
  end

  it 'should set session lifetime to 1 week' do
    last_access_time = DateTime.now
    allow(Clock).to receive(:now).and_return(last_access_time)
    post :login, :user_name => @user.user_name, :password => "test_password", :imei => 'TEST_IMEI'
    expect(controller.session[:last_access_time]).to eq(last_access_time.rfc2822)
    expect(response).to be_success
  end

  describe "#register" do
    it "should set verified status to false" do
      expect(User).to receive(:find_by_user_name).and_return(nil)
      expect(User).to receive(:new).with("user_name" => "salvador", "verified" => false, "password" => "password", "password_confirmation" => "password").and_return(user = "some_user")
      expect(user).to receive :save!

      post :register, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}

      expect(response).to be_ok
    end

    it "should not attempt to create a user if already exists" do
      expect(User).to receive(:find_by_user_name).and_return("something that is not nil")
      expect(User).not_to receive(:new)

      post :register, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}
      expect(response).to be_ok
    end
  end

end
