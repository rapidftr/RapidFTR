require 'spec_helper'

describe "home/index.html.erb" do
  it "should display time for notifications in yyyy/mm/dd format for users who do not already exist" do
    mock_password_recovery_request = double("PasswordRecoveryRequest", :user_name =>'mjhasson', :created_at => Time.parse("Jan 31 2011"), :to_param => '123')
    assign(:notifications,[ mock_password_recovery_request ])

    view.stub(:can?).with(:update, User).and_return(true)

    render :template=>'home/_notifications'
    rendered.should be_include("mjhasson at 2011/01/31.")
  end

  it "should display time for notifications in yyyy/mm/dd format for users who do exist" do
    mock_password_recovery_request = double("PasswordRecoveryRequest", :user_name =>'jpretorius', :created_at => Time.parse("Jan 31 2011"), :to_param => '124')
    assign(:notifications, [ mock_password_recovery_request ])

    # to_param is because the CI build is failing when trying to generate named route for this mock object - CG Nov 24 2011
    mock_user = double("user", :user_name => 'jpretorius', :to_param => 'foo')
    User.stub(:find_by_user_name).and_return(mock_user)
    view.stub(:can?).with(:update, User).and_return(true)

    render :template=>'home/_notifications'
    rendered.should be_include("jpretorius")
    rendered.should be_include("at 2011/01/31.")
  end
end
