require 'spec_helper'

describe HomeController, :type => :controller do
  describe 'User#force_password_change?' do
    it 'should redirect to change password page' do
      user = User.new(:user_name => 'admin', :force_password_change => true)
      fake_login_as_user(user)
      get :index
      expect(response).to redirect_to '/users/change_password'
    end
  end
end
