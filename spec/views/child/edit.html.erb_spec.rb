require 'spec_helper'

class FormSection;
end

describe "children/edit.html.erb" do

  before :each do
    @enabled_form_section = FormSection.new :unique_id => "section_name", :enabled=>"true"
    @disabled_form_section = FormSection.new :unique_id => "section_name", :enabled=>"false"
    @disabled_form_section.add_field Field.new_text_field("age")
    @disabled_form_section.add_field Field.new_radio_button("gender", ["male", "female"])
    assigns[:form_sections] = [@enabled_form_section, @disabled_form_section]
    @child = Child.new("_id" => "id12345")
    assigns[:child] = @child
  end

  it "renders a form that posts to the children url" do
    render

    response.should have_selector("form", :action => child_path(@child))
  end

  it "renders the children/form_section partial" do
    template.should_receive(:render).with(
            :partial => "form_section",
            :collection => [@enabled_form_section]
    )

    render
  end

  it "does not render fields found on a disabled FormSection" do
    render

    response.should_not have_selector("dl.section_name dt") do |fields|
      fields[0].should_not contain("Age")
      fields[1].should_not contain("Gender")
    end
  end
end
