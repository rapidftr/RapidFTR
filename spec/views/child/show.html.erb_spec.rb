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

      child = Child.new :age => "27", :gender => "male", :date_of_separation => "1-2 weeks ago", :unique_identifier => "georgelon12345", :_id => "id12345"

      assigns[:form_sections] = [form_section]
      assigns[:child] = child

      render

      response.should have_selector("dl.section_name dt") do |fields|
        fields[0].should contain("Age")
        fields[1].should contain("Gender")
        fields[2].should contain("Date of separation")
      end
      
      response.should have_selector("dl.section_name dd") do |fields|
        fields[0].should contain("27")
        fields[1].should contain("male")
        fields[2].should contain("1-2 weeks ago")
      end
    end

    it "does not render fields found on a disabled FormSection" do

      form_section = FormSection.new :unique_id => "section_name", :enabled => "false"
      form_section.add_field Field.new_text_field("age")
      form_section.add_field Field.new_radio_button("gender", ["male", "female"])

      child = Child.new :age => "27", :gender => "male", :unique_identifier => "georgelon12345", :_id => "id12345"

      assigns[:form_sections] = [form_section]
      assigns[:child] = child

      render

      response.should_not have_selector("dl.section_name dt") do |fields|
        fields[0].should_not contain("Age")
        fields[1].should_not contain("Gender")
      end
    end

  end

end
