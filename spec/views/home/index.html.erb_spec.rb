require 'spec_helper'

describe "home/index.html.erb" do
  it "should display time for notifications in yyyy/mm/dd format for users who do not already exist" do
    mock_password_recovery_request = mock("PasswordRecoveryRequest", :user_name =>'mjhasson', :created_at => Time.parse("Jan 31 2011"))
    assigns[:notifications] = [ mock_password_recovery_request ]
    
    template.stub!(:is_admin?).and_return(true)
  
    render :template=>'home/_notifications'
    response.should include_text("mjhasson at 2011/01/31.")
  end
  
  it "should display time for notifications in yyyy/mm/dd format for users who do exist" do
    mock_password_recovery_request = mock("PasswordRecoveryRequest", :user_name =>'jpretorius', :created_at => Time.parse("Jan 31 2011"))
    assigns[:notifications] = [ mock_password_recovery_request ]
    
    User.stub!(:find_by_user_name).and_return(mock("user", :user_name => 'jpretorius'))
    template.stub!(:is_admin?).and_return(true)
  
    render :template=>'home/_notifications'
    response.should include_text("jpretorius")
    response.should include_text("at 2011/01/31.")
  end
end