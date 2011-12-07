require 'spec_helper'

describe PasswordRecoveryRequestsController do

    def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
    end

  it "should create password recovery request" do
    User.should_receive(:find_by_user_name).with("ygor").and_return(mock_user)
    PasswordRecoveryRequest.should_receive(:create).with({"user_name" => "ygor"}).and_return(mock)

    post :create, {:password_recovery_request => {:user_name => "ygor"}}

    response.flash[:notice].should == "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."

    response.should render_template(:create)
  end
end
