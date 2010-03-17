require 'spec_helper'

class Schema;
end

describe "children/show.html.erb" do

  describe "displaying a child's details"  do

    it "displays the Child's photo"

    it "renders all fields found on the FormSection" do

      form_section = FormSection.new "section_name"
      form_section.add_field Field.new("age", Field::TEXT_FIELD, [], "27")
      form_section.add_field Field.new("gender", Field::RADIO_BUTTON, ["male", "female"], "male")
      form_section.add_field Field.new("date_of_separation", Field::SELECT_BOX, ["1-2 weeks ago", "More than"], "1-2 weeks ago")


      assigns[:form_sections] = [form_section]

      assigns[:child] = Child.new("unique_identifier" => "georgelon12345", "_id" => "id12345")

      render

      response.should have_selector("dt:first") do |dt|
        dt.should contain("Unique Id")
      end
      response.should have_selector("dd:first") do |dd|
        dd.should contain("georgelon12345")
      end

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

  end

end
