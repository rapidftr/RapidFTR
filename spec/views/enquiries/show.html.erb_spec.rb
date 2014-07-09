require 'spec_helper'

class Schema;
end

describe "enquiries/show.html.erb" do

  describe "displaying an enquiry's details"  do
    before :each do
      @user = mock('user', :has_permission? => true, :user_name => 'name', :id => 'test-user-id')
      controller.stub(:current_user).and_return(@user)
      view.stub(:current_user).and_return(@user)
      view.stub(:logged_in?).and_return(true)
      view.stub(:current_user_name).and_return('name')
      view.instance_variable_set(:@exclude_tabs, [])
      @form_section = FormSection.new :unique_id => "section_name"
      @enquiry = Enquiry.create(:enquirer_name => 'Someone', :criteria => {'name' => 'child name'})

      assign(:form_sections, [@form_section])
      assign(:enquiry, @enquiry)
      assign(:current_user, User.new)
      assign(:duplicates, Array.new)
    end

    it "renders all fields found on the FormSection" do
      @form_section.add_field Field.new_text_field("age", "Age")
      @form_section.add_field Field.new_radio_button("gender", ["male", "female"], "Gender")
      @form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than"], "Date of separation")

      render

      rendered.should have_tag(".section_name") do
        with_tag(".profile-section-label", /Age/)
        with_tag(".profile-section-label", /Gender/)
        with_tag(".profile-section-label", /Date of separation/)
      end

      rendered.should have_tag(".key") do
        with_tag(".value", "27")
        with_tag(".value", "male")
        with_tag(".value", "1-2 weeks ago")
      end
    end

    it "does not render fields found on a disabled FormSection" do
      @form_section['enabled'] = false

      render

      rendered.should_not have_tag("dl.section_name dt")
    end

    it "does not render fields found on an excluded FormSection" do
      view.instance_variable_set(:@exclude_tabs, ['section_name'])

      render

      rendered.should_not have_tag("dl.section_name dt")
    end

  end

end
