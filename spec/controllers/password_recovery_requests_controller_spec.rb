require 'spec_helper'

describe PasswordRecoveryRequestsController do

  before :each do
    controller.stub(:current_session).and_return(nil)
  end

  it "should create password recovery request" do
    valid_params = {"user_name" => "ygor"}
    PasswordRecoveryRequest.should_receive(:new).with(valid_params).and_return(recovery_request = mock)
    recovery_request.should_receive(:save).and_return true

    post :create, :password_recovery_request => valid_params

    flash[:notice].should == "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."
    response.should redirect_to(login_path)
  end

  it "should report error when password recovery request is invalid" do
    invalid_params = {"user_name" => ""}
    PasswordRecoveryRequest.should_receive(:new).with(invalid_params).and_return(recovery_request = mock)
    recovery_request.should_receive(:save).and_return false

    post :create, :password_recovery_request => invalid_params

    response.should render_template(:new)
    assigns[:password_recovery_request].should == recovery_request
  end
end
