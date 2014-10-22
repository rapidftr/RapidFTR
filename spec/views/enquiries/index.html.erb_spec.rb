require 'spec_helper'

describe 'enquiries/index.html.erb', :type => :view do

  before :each do
    @form_sections = []

    form = create(:form, :name => Enquiry::FORM_NAME)
    @form_sections << create(:form_section, :unique_id => 'enquiry_criteria', :name => 'Enquiry Criteria', :form => form,
                             :fields => [build(:field, :name => 'enquirer_name', :display_name => 'Enquirer Name'), build(:field, :name => 'child_name', :display_name => 'Child Name')])
    @form_sections << create(:form_section, :unique_id => 'potential_matches', :name => 'Matches', :form => form)

    @highlighted_fields = [
      Field.new(:name => 'enquirer_name', :display_name => 'Enquiry Criteria', :visible => true),
      Field.new(:name => 'child_name', :display_name => 'child_name', :visible => true)]
    allow(Form).to receive(:find_by_name).and_return(double('Form', :sorted_highlighted_fields => @highlighted_fields, :title_fields => []))
  end

  it 'display all enquiries' do
    @user = double('user', :has_permission? => true, :user_name => 'name', :id => 'test-user-id')

    enquiries = []
    enquiries << create(:enquiry, :enquirer_name => 'Foo Bar', :child_name => 'John Doe', :created_at => 'July 19 2010 13:05:32UTC')
    enquiries << create(:enquiry, :enquirer_name => 'John Doe', :child_name => 'Jane Doe', :create_at => 'July 19 2010 13:05:32UTC')

    allow(@user).to receive(:localize_date).and_return('July 19 2010 13:05:32UTC')
    allow(controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:logged_in?).and_return(true)
    allow(view).to receive(:current_user_name).and_return('name')
    assign(:current_user, User.new)

    enquiries.stub :total_entries => 100, :offset => 1, :total_pages => 10, :current_page => 1

    assign(:enquiries, enquiries)

    render :template => 'enquiries/index', :layout => 'layouts/application'

    expect(rendered).to have_content('Foo Bar')
    expect(rendered).to have_content('Jane Doe')
  end
end
