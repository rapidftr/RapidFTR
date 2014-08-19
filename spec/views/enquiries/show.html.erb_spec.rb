require 'spec_helper'

describe 'enquiries/show.html.erb', :type => :view do

  it 'display all form sections for the enquiries form' do
    @user = double('user', :has_permission? => true, :user_name => 'name', :id => 'test-user-id')
    @form_sections = []

    form = create(:form, :name => Enquiry::FORM_NAME)
    @form_sections << create(:form_section, :unique_id => 'enquiry_criteria', :name => 'Enquiry Criteria', :form => form, :fields => [build(:field, :name => 'enquirer_name')])
    @form_sections << create(:form_section, :unique_id => 'potential_matches', :name => 'Potential Matches', :form => form)

    enquiry = create(:enquiry, :enquirer_name => 'Foo Bar', :child_name => 'John Doe', :created_at => 'July 19 2010 13:05:32UTC')

    allow(controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:logged_in?).and_return(true)
    allow(view).to receive(:current_user_name).and_return('name')
    assign(:forms_sections, @form_sections)
    assign(:enquiry, enquiry)
    assign(:current_user, User.new)

    render :template => 'enquiries/show', :layout => 'layouts/application'

    expect(rendered).to have_tag('#tab_enquiry_criteria')
    expect(rendered).to have_tag('#tab_potential_matches')
  end
end
