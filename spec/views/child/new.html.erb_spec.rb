require 'spec_helper'

describe "children/new.html.erb" do

  before :each do
    @form_section = FormSection.new :unique_id => "section_name"
    assigns[:form_sections] = [@form_section]
  end

  it "renders a form that posts to the children url" do
    render
    response.should have_tag("form[action='#{children_path}']")
  end

  it "renders the children/form_section partial" do
    template.should_receive(:render).with(
            :partial => "form_section",
            :collection => [@form_section])
    render
  end
	it "renders a hidden field for the posted_from attribute" do
		render
		response.should have_tag("input[name='child[posted_from]'][value='Browser']")
	end
end
