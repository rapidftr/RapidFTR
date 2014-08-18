require 'spec_helper'

describe 'home/index.html.erb', :type => :view do
  it 'should display time for notifications in yyyy/mm/dd format for users who do not already exist' do
    mock_password_recovery_request = double('PasswordRecoveryRequest', :user_name => 'mjhasson', :created_at => Time.parse('Jan 31 2011'), :to_param => '123')
    assign(:notifications, [mock_password_recovery_request])

    allow(view).to receive(:can?).with(:update, User).and_return(true)

    render :template => 'home/_notifications'
    expect(rendered).to be_include('mjhasson at 2011/01/31.')
  end

  it 'should display time for notifications in yyyy/mm/dd format for users who do exist' do
    mock_password_recovery_request = double('PasswordRecoveryRequest', :user_name => 'jpretorius', :created_at => Time.parse('Jan 31 2011'), :to_param => '124')
    assign(:notifications, [mock_password_recovery_request])

    # to_param is because the CI build is failing when trying to generate named route for this mock object - CG Nov 24 2011
    mock_user = double('user', :user_name => 'jpretorius', :to_param => 'foo')
    allow(User).to receive(:find_by_user_name).and_return(mock_user)
    allow(view).to receive(:can?).with(:update, User).and_return(true)

    render :template => 'home/_notifications'
    expect(rendered).to be_include('jpretorius')
    expect(rendered).to be_include('at 2011/01/31.')
  end
end
