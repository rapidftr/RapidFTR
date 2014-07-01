require 'spec_helper'

describe Api::SessionsController do

  before :each do
    @admin_role = create :role
    @user = create :user, :password => 'test_password', :password_confirmation => 'test_password', :role_ids => [ @admin_role.name ]
    controller.stub! :mobile_db_key => 'TEST_DB_KEY'
  end

  it 'should login' do
    I18n.stub(:default_locale).and_return("zz")
    post :login, :user_name => @user.user_name, :password => 'test_password', :imei => 'TEST_IMEI'

    response.should be_success
    JSON.parse(response.body).should include({
      "db_key" => 'TEST_DB_KEY',
      "organisation" => @user.organisation,
      "language" => "zz",
      "verified" => @user.verified?
    })
  end

  it 'should logout' do
    session = fake_login @user
    session.should_receive(:destroy).and_return(true)

    post :logout
    response.should be_success
  end

  it 'should set session lifetime to 1 week' do
    last_access_time = DateTime.now
    Clock.stub(:now).and_return(last_access_time)
    post :login, :user_name => @user.user_name, :password => "test_password", :imei => 'TEST_IMEI'
    controller.session[:last_access_time].should == last_access_time.rfc2822
    response.should be_success
  end

  describe "#register" do
    it "should set verified status to false" do
      User.should_receive(:find_by_user_name).any_number_of_times.and_return(nil)
      User.should_receive(:new).with("user_name" => "salvador", "verified" => false, "password" => "password", "password_confirmation" => "password").and_return(user = "some_user")
      user.should_receive :save!

      post :register, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}

      response.should be_ok
    end

    it "should not attempt to create a user if already exists" do
      User.should_receive(:find_by_user_name).any_number_of_times.and_return("something that is not nil")
      User.should_not_receive(:new)

      post :register, {:format => :json, :user => {:user_name => "salvador", "unauthenticated_password" => "password"}}
      response.should be_ok
    end
  end

end
