require 'spec_helper'

describe 'shared/_header_links.html.erb', :type => :view do
  let(:permissions) { [] }
  let (:form) { create :form}
  let(:user) { stub_model User, :id => 'test_id', :user_name => 'test_user', :permissions => permissions }

  subject do
    controller.stub :current_user => user
    view.stub :current_user => user
    render :partial => 'shared/header_links'
  end

  describe 'when logged out' do
    let(:user) { nil }
    it { is_expected.not_to have_content('Welcome') }
    it { is_expected.not_to have_link('Logout') }
    it { is_expected.not_to have_link('My Account') }
    it { is_expected.not_to have_link('System settings') }
    it { is_expected.to have_link('Contact & Help', :href => contact_users_path) }
  end

  describe 'when logged in' do
    it { is_expected.to have_content('Welcome test_user') }
    it { is_expected.to have_link('Logout', :href => logout_path) }
    it { is_expected.to have_link('My Account', :href => user_path(user.id)) }
    it { is_expected.not_to have_link('System settings') }
    it { is_expected.to have_link('Contact & Help', :href => contact_users_path) }
    it { is_expected.not_to have_link('CHILDREN', :href => children_path)}
    it { is_expected.not_to have_link('FORMS', :href => form_form_sections_path(form.id))}
    it { is_expected.not_to have_link('USERS', :href => users_path)}
    it { is_expected.not_to have_link('DEVICES', :href => devices_path)}
  end

  describe 'with all permission' do
    let(:permissions) { Permission.all_permissions }
    it { is_expected.to have_link('System settings', :href => admin_path) }
  end

  describe 'with system settings permission' do
    let(:permissions) { [Permission::SYSTEM[:system_users]] }
    it { is_expected.to have_link('System settings', :href => admin_path) }
  end

  describe 'with manage forms permisssion' do
    let(:permissions) { [Permission::SYSTEM[:highlight_fields]] }
    it { is_expected.to have_link('System settings', :href => admin_path) }
  end

end
