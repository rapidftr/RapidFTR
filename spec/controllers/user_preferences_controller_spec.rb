require 'spec_helper'

describe UserPreferencesController, :type => :controller do

  before :each do
    fake_field_worker_login
  end

  after :each do
    I18n.default_locale = :en
  end

  it 'should save the given local in user' do
    mock_user = double('user', :user_name => 'UserName', :locale => 'en', :force_password_change? => false)
    user_params = {'locale' => 'fr'}
    expect(User).to receive(:find_by_user_name).at_least(:once).and_return(mock_user)
    expect(mock_user).to receive(:update_attributes).with(user_params)
    put :update, :id => 'user_id', :user => user_params
    assert_redirected_to root_path
  end

  it 'should flash a update message when the system language is changed' do
    mock_user = double('user', :user_name => 'UserName', :locale => 'en', :force_password_change? => false)
    user_params = {'locale' => 'zh'}
    expect(User).to receive(:find_by_user_name).at_least(:once).and_return(mock_user)
    expect(mock_user).to receive(:update_attributes).with(user_params).and_return(true)
    put :update, :id => 'user_id', :user => {'locale' => 'zh'}
    expect(flash[:notice]).to eq('The change was successfully updated.')
  end

end
