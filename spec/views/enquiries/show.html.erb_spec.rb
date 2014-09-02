require 'spec_helper'

describe 'enquiries/show.html.erb', :type => :view do

  before :each do
    reset_couchdb!
    @user = double('user', :has_permission? => true, :user_name => 'name', :id => 'test-user-id')
    @form_sections = []
    @potential_matches = []

    form = create(:form, :name => Enquiry::FORM_NAME)
    @form_sections << create(:form_section, :unique_id => 'enquiry_criteria', :name => 'Enquiry Criteria', :form => form, :fields => [build(:field, :name => 'enquirer_name')])
    @form_sections << create(:form_section, :unique_id => 'potential_matches', :name => 'Potential Matches', :form => form)

    @enquiry = create(:enquiry, :enquirer_name => 'Foo Bar', :child_name => 'John Doe', :created_at => 'July 19 2010 13:05:32UTC')

    allow(@user).to receive(:localize_date).and_return('July 19 2010 13:05:32UTC')
    allow(controller).to receive(:current_user).and_return(@user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:logged_in?).and_return(true)
    allow(view).to receive(:current_user_name).and_return('name')
    assign(:forms_sections, @form_sections)
    assign(:enquiry, @enquiry)
    assign(:current_user, User.new)

    @highlighted_fields = [
      Field.new(:name => 'field_2', :display_name => 'field display 2', :visible => true),
      Field.new(:name => 'field_4', :display_name => 'field display 4', :visible => true)]
    allow(Form).to receive(:find_by_name).and_return(double('Form', :sorted_highlighted_fields => @highlighted_fields))
  end

  it 'display all form sections for the enquiries form' do
    render :template => 'enquiries/show', :layout => 'layouts/application'
    expect(rendered).to have_tag('#tab_enquiry_criteria')
    expect(rendered).to have_tag('#tab_potential_matches')
  end

  it 'display potential matches section' do
    @potential_matches << create(:child, :name => 'John')
    @potential_matches << create(:child, :name => 'Jane')

    render :template => 'enquiries/show', :layout => 'layouts/application'
    expect(rendered).to have_tag('#tab_potential_matches')
  end

  describe 'rendering matching child partial' do
    it 'should a have link to mark child as not a match' do
      fields =[build(:field, :name => 'name')]
      child = create(:child, :name => 'Foo Bar')

      render :template => "children/_summary_row", :locals => {:child => child, :checkbox => false, :highlighted_fields => fields, :rendered_by_show_enquiry => true}

      expect(rendered).to match /Mark as not matching/
      expect(rendered).to have_link('Mark as not matching', :href => "/enquiries/#{@enquiry.id}/potential_matches/#{child.id}")
    end

    it 'should not have link to mark child as not a match when flag is not passed' do
      fields =[build(:field, :name => 'name')]
      child = create(:child, :name => 'Foo Bar')

      render :template => "children/_summary_row", :locals => {:child => child, :checkbox => false, :highlighted_fields => fields} 

      expect(rendered).not_to match /Mark as not matching/
      expect(rendered).not_to have_link('Mark as not matching', :href => "/enquiries/#{@enquiry.id}")
    end

  end
end
