require 'spec_helper'

describe SessionsController do

  it "should respond with text ok" do
    get :active
    response.body.should == 'OK'
  end

  it "should return the db encryption key when the user is authenticated successfully via a mobile device" do
    MobileDbKey.should_receive(:find_or_create_by_imei).with("IMEI_NUMBER").and_return(mock(:db_key => "unique_key"))
    Login.stub(:new).and_return(mock(:authenticate_user =>
                              mock_model(Session, :authenticate_user => true, :device_blacklisted? => false, :imei => "IMEI_NUMBER",
                                   :save => true, :put_in_cookie => true, :user_name => "dummy", :token => "some_token", :extractable_options? => false)))
    post :create, :user_name => "dummy", :password => "dummy", :imei => "IMEI_NUMBER", :format => "json"

    JSON.parse(response.body)["db_key"].should == "unique_key"
  end

end
