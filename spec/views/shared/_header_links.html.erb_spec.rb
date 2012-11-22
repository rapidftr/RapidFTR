require 'spec_helper'

describe 'shared/_header_links.html.erb' do
  let(:permissions) { [] }
  let(:user) { stub_model User, :id => 'test_id', :user_name => 'test_user', :permissions => permissions }

  subject do
    controller.stub :current_user => user
    view.stub :current_user => user
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
    it { should have_content('Welcome test_user') }
    it { should have_link('Logout', logout_path) }
    it { should have_link('My Account', user_path(user.id)) }
    it { should_not have_link('System settings') }
    it { should have_link('Contact & Help', :href => contact_information_path("administrator")) }
  end

  describe 'with admin permission' do
    let(:permissions) { [Permission::ADMIN[:admin]] }
    it { should have_link('System settings', admin_path) }
  end

  describe 'with system settings permission' do
    let(:permissions) { [Permission::SYSTEM[:settings]] }
    it { should have_link('System settings', admin_path) }
  end

  describe 'with manage forms permisssion' do
    let(:permissions) { [Permission::SYSTEM[:highlight_fields]] }
    it { should have_link('System settings', admin_path) }
  end

end
