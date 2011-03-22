require 'spec_helper'

describe "children/edit.html.erb" do

  before :each do
    @form_section = FormSection.new :unique_id => "section_name", :enabled=>"true"
    assigns[:form_sections] = [@form_section]
    @child = Child.new("_id" => "id12345")
    assigns[:child] = @child
  end

  it "renders a form that posts to the children url" do
    render
    response.should have_tag("form[action='#{child_path(@child)}']")
  end

  it "renders the children/form_section partial" do
    template.should_receive(:render).with(
            :partial => "form_section",
            :collection => [@form_section])
    render
  end
end
