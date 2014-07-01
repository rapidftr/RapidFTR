require 'spec_helper'

describe SessionsController do

  it "should respond with text ok" do
    controller.should_not_receive(:extend_session_lifetime)
    controller.should_not_receive(:check_authentication)
    get :active
    response.body.should == 'OK'
  end

  it "should return the required fields when the user is authenticated successfully via a mobile device" do
    MobileDbKey.should_receive(:find_or_create_by_imei).with("IMEI_NUMBER").and_return(mock(:db_key => "unique_key"))
    mock_user = mock({:organisation => "TW", :verified? => true})
    User.should_receive(:find_by_user_name).with(anything).and_return(mock_user)
    Login.stub(:new).and_return(mock(:authenticate_user =>
                              mock_model(Session, :authenticate_user => true, :device_blacklisted? => false, :imei => "IMEI_NUMBER",
                                   :save => true, :put_in_cookie => true, :user_name => "dummy", :token => "some_token", :extractable_options? => false)))

    access_time = DateTime.now
    Clock.stub(:now).and_return(access_time)

    post :create, :user_name => "dummy", :password => "dummy", :imei => "IMEI_NUMBER", :format => "json"

    controller.session[:last_access_time].should == access_time.rfc2822

    json = JSON.parse response.body
    json["db_key"].should == "unique_key"
    json["organisation"].should == "TW"
    json["language"].should == "en"
    json["verified"].should == mock_user.verified?
  end

end
