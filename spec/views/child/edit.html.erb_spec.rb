require 'spec_helper'
include Rails.application.routes.url_helpers

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

  xit "renders the children/form_section partial" do
    view.should_receive(:render).with(
            :partial => "form_section",
            :collection => [@form_section])
    render
  end
end
