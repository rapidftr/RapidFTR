require 'spec_helper'
require 'nokogiri'

describe "advanced_search/index.html.erb", :type => :view do
  it "should not show hidden fields" do
    form_section = build :form_section, fields: [
      build(:text_field),
      build(:text_field, visible: false)
    ]
    search_form = Forms::SearchForm.new(ability: nil, params: {})
    search_form.send :parse_params

    assign(:form_sections, [ form_section ])
    assign(:search_form, search_form)
    render
    document = Nokogiri::HTML(rendered)
    expect(document.css(".field").count).to eq(1)
  end

  it "show navigation links for logged in user" do
    form_section = build :form_section, fields: []
    search_form = Forms::SearchForm.new(ability: nil, params: {})
    search_form.send :parse_params
    user = build :super_user

    assign(:form_sections, [ form_section ])
    assign(:search_form, search_form)

    allow(view).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_user_name).and_return(user.user_name)

    allow(controller).to receive(:logged_in?).and_return(true)
    allow(view).to receive(:logged_in?).and_return(true)

    render :template => "advanced_search/index", :layout => "layouts/application"

    expect(rendered).to have_tag("nav")
    expect(rendered).to have_link "CHILDREN", :href => children_path
  end

  it "show not navigation links when no user logged in" do
    form_section = build :form_section, fields: []
    search_form = Forms::SearchForm.new(ability: nil, params: {})
    search_form.send :parse_params

    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:logged_in?).and_return(false)
    assign(:form_sections, [ form_section ])
    assign(:search_form, search_form)
    render :template => "advanced_search/index", :layout => "layouts/application"

    expect(rendered).not_to have_tag("nav")
    expect(rendered).not_to have_link "CHILDREN", :href => children_path
  end
end
