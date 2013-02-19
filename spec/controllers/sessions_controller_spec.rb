require 'spec_helper'

describe SessionsController do

  it "should respond with text ok" do
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
    post :create, :user_name => "dummy", :password => "dummy", :imei => "IMEI_NUMBER", :format => "json"

    JSON.parse(response.body)["db_key"].should == "unique_key"
    JSON.parse(response.body)["organisation"].should == "TW"
    JSON.parse(response.body)["language"].should == "en"
    JSON.parse(response.body)["verified"].should == mock_user.verified?
  end

end
