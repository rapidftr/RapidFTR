require 'spec_helper'

describe PasswordRecoveryRequestsController do

  it "should create password recovery request" do

    @mock_password_recovery_request = stub(:save => true)
    #@mock_password_recovery_request.stub!(:save).and_return(true)
    PasswordRecoveryRequest.should_receive(:new).with({"username" => "ygor"}).and_return(@mock_password_recovery_request)

    post :create, {:password_recovery_request => {:username => "ygor"}}

    flash.now[:notice].should == "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."

    response.should render_template(:create)

  end
end
