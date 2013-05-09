require 'spec_helper'

describe UserPreferencesController do

  before :each do
    fake_field_worker_login
  end

  after :each do
    I18n.default_locale = :en
  end

  it "should save the given local in user" do
    mock_user = mock("user", :user_name => "UserName", :locale => 'en')
    user_params = {"locale" => "fr"}
    User.should_receive(:find_by_user_name).any_number_of_times.and_return(mock_user)
    mock_user.should_receive(:update_attributes).with(user_params)
    put :update, {:id => 'user_id', :user => user_params}
    assert_redirected_to root_path
  end

  it "should flash a update message when the system language is changed" do
    mock_user = mock("user", :user_name => "UserName", :locale => 'en')
    user_params = {"locale" => "zh"}
    User.should_receive(:find_by_user_name).any_number_of_times.and_return(mock_user)
    mock_user.should_receive(:update_attributes).with(user_params).and_return(true)
    put :update, {:id => 'user_id',:user =>{"locale" => "zh"}}
    flash[:notice].should =="The change was successfully updated."
  end

end
