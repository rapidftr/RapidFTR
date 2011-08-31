require 'spec_helper'

describe PasswordRecoveryRequestsController do

  it "should create password recovery request" do
    PasswordRecoveryRequest.should_receive(:create).with({"username" => "ygor"}).and_return(mock)

    post :create, {:password_recovery_request => {:username => "ygor"}}

    response.flash[:notice].should == "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."

    response.should render_template(:create)
  end
end
