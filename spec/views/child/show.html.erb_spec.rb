require 'spec_helper'

class Schema;
end

describe "children/show.html.erb" do

  describe "displaying a child's details"  do

    it "displays the Child's photo"

    it "renders all fields found on the FormSection" do

      form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
      form_section.add_field Field.new_text_field("age", "Age")
      form_section.add_field Field.new_radio_button("gender", ["male", "female"], "Gender")
      form_section.add_field Field.new_select_box("date_of_separation", ["1-2 weeks ago", "More than"], "Date of separation")

      child = Child.new(:age => "27", :gender => "male", :date_of_separation => "1-2 weeks ago", :unique_identifier => "georgelon12345", :_id => "id12345")
      child.stub!(:has_one_interviewer?).and_return(true)

      assigns[:form_sections] = [form_section]
      assigns[:child] = child

      render

      response.should have_tag(".section_name") do
        with_tag(".profile-section-label", /Age/)
        with_tag(".profile-section-label", /Gender/)
        with_tag(".profile-section-label", /Date of separation/)
      end

      response.should have_tag(".section_name .profile-section-value") do
        with_tag(".profile-section-value", "27")
        with_tag(".profile-section-value", "male")
        with_tag(".profile-section-value", "1-2 weeks ago")
      end
    end

    it "does not render fields found on a disabled FormSection" do

      form_section = FormSection.new :unique_id => "section_name", :enabled => "false"
      form_section.add_field Field.new_text_field("age")
      form_section.add_field Field.new_radio_button("gender", ["male", "female"])

      child = Child.new(:age => "27", :gender => "male", :unique_identifier => "georgelon12345", :_id => "id12345")
      child.stub!(:has_one_interviewer?).and_return(true)

      assigns[:form_sections] = [form_section]
      assigns[:child] = child

      render

      response.should_not have_tag("dl.section_name dt")
    end

    describe "interviewer details" do
      it "should show registered by details and no link to change log if child has not been updated" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith')
        child.stub!(:has_one_interviewer?).and_return(true)

        assigns[:form_sections] = [form_section]
        assigns[:child] = child

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should_not have_tag("#interviewer_details", /and others/)
        response.should_not have_tag("#interviewer_details", /Last updated:/)
      end

      it "should show link to change log if child has been updated by multiple people" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :last_updated_by => "jdoe")
        child.stub!(:has_one_interviewer?).and_return(false)

        assigns[:form_sections] = [form_section]
        assigns[:child] = child

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should have_tag("#interviewer_details", /and others/)
        response.should have_tag("#interviewer_details", /Last updated:/)
      end

      it "should not show link to change log if child was registered by and updated again by only the same person" do
        form_section = FormSection.new :unique_id => "section_name", :enabled => "true"
        child = Child.new(:age => "27", :unique_identifier => "georgelon12345", :_id => "id12345", :created_by => 'jsmith', :last_updated_by => "jsmith")
        child.stub!(:has_one_interviewer?).and_return(true)

        assigns[:form_sections] = [form_section]
        assigns[:child] = child

        render

        response.should have_tag("#interviewer_details", /Registered by: jsmith/)
        response.should_not have_tag("#interviewer_details", /and others/)
      end
    end

  end

end
