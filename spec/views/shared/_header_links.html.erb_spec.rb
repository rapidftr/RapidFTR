require 'spec_helper'

describe 'shared/_header_links.html.erb' do
  before :each do
    view.stub :current_user => user
    User.stub :find_by_user_name => user
  end

  subject do
    render :partial => 'shared/header_links'
  end

  describe 'when logged out' do
    let(:user) { nil }
    it { should_not have_content('Welcome') }
    it { should_not have_link('Logout') }
    it { should_not have_link('My Account') }
    it { should_not have_link('System settings') }
    it { should have_link('Contact & Help', :href => contact_information_path("administrator")) }
  end

  describe 'when logged in' do
    let(:user) do
      user = User.new :user_name => 'test_user'
      user.stub :id => 'testid'
      user
    end

    it { should have_content('Welcome test_user') }
    it { should have_link('Logout', logout_path) }
    it { should have_link('My Account', user_path(user.id)) }
    it { should_not have_link('System settings') }
    it { should have_link('Contact & Help', :href => contact_information_path("administrator")) }

    describe 'as admin' do
      before :each do
        view.stub :is_admin? => true
      end

      it { should have_link('System settings', admin_path) }
    end
  end

end
