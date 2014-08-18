require 'spec_helper'

describe 'children/new.html.erb', :type => :view do

  before :each do
    @form_section = FormSection.new :unique_id => 'section_name'
    assign(:form_sections, [@form_section])
  end

  it 'renders a form that posts to the children url' do
    render
    expect(rendered).to have_tag("form[action='#{children_path}']")
  end

  xit 'renders the children/form_section partial' do
    # This should be a controller spec
    render
    expect(rendered).to render_template(:partial => '_form_section', :collection => [@form_section])
  end

  it 'renders a hidden field for the posted_from attribute' do
    render
    expect(rendered).to have_tag("input[name='child[posted_from]'][value='Browser']")
  end
end
