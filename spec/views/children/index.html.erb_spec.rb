require 'spec_helper'

describe 'children/index.html.erb', :type => :view do

  before do
    @user = double('user', :has_permission? => true, :user_name => 'name', :id => 'test-user-id')

    allow(@user).to receive(:localize_date).and_return('July 19 2010 13:05:32UTC')
    allow(controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:logged_in?).and_return(true)
    allow(view).to receive(:current_user_name).and_return('name')

    @highlighted_fields = [
      Field.new(:name => 'child_father', :display_name => 'Father of child', :visible => true),
      Field.new(:name => 'child_name', :display_name => 'child_name', :visible => true)]
    allow(Form).to receive(:find_by_name).and_return(double('Form', :sorted_highlighted_fields => @highlighted_fields, :title_fields => []))
  end

  context 'when enquiries are turned off' do
    before :each do
      @enable_enquiries = SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => 0)
    end

    after :each do
      @enable_enquiries.destroy
    end

    it 'should not show the reunited filter' do
      render
      expect(rendered).to_not have_tag('option[value="reunited"]')
    end
  end

  context 'when enquiries are turned on' do
    before :each do
      @enable_enquiries = SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => 1)
    end

    after :each do
      @enable_enquiries.destroy
    end

    it 'should show the reunited filter' do
      render
      expect(rendered).to have_tag('option[value="reunited"]')
    end
  end
end
