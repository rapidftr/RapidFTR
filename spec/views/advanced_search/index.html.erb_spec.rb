require 'spec_helper'
require 'nokogiri'

describe "advanced_search/index.html.erb", :type => :view do
  it "should not show hidden fields" do
    fields = [Field.new(:name => 'my_field', :display_name => 'My Field', :visible => true, :type => Field::TEXT_FIELD),
              Field.new(:name => 'my_hidden_field', :display_name => 'My Hidden Field', :visible=> false, :type => Field::TEXT_FIELD)]
    form_sections = [FormSection.new("name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => fields)]
    assign(:forms, form_sections)
    assign(:criteria_list, [])
    render
    document = Nokogiri::HTML(rendered)
    expect(document.css(".field").count).to eq(1)
  end

  it "show navigation links for logged in user" do
    user = stub_model(User, :user_name => "bob", :has_permission? => true)
    form_sections = [FormSection.new("name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => [])]
    assign(:forms, form_sections)
    assign(:criteria_list, [])

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
    form_sections = [FormSection.new("name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => [])]
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:logged_in?).and_return(false)
    assign(:forms, form_sections)
    assign(:criteria_list, [])
    render :template => "advanced_search/index", :layout => "layouts/application"

    expect(rendered).not_to have_tag("nav")
    expect(rendered).not_to have_link "CHILDREN", :href => children_path
  end
end
