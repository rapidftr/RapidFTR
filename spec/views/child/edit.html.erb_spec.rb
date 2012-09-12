require 'spec_helper'

describe "children/edit.html.erb" do

  before :each do
    @form_section = FormSection.new :unique_id => "section_name", :enabled=>"true"
    assign(:form_sections, [@form_section])
    @child = Child.create(:name => "name")
    assign(:child, @child)
  end

  it "renders a form that posts to the children url" do
    render
    rendered.should have_tag("form[action='#{child_path(@child)}']")
  end

  it "renders the children/form_section partial" do
    render
    rendered.should render_template(:partial =>  "_form_section",:collection => [@form_section])
  end
end
