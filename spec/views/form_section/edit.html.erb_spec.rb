require 'spec_helper'
require 'nokogiri'

describe "form_section/edit.html.erb" do
  it "should not allow to show/hide fields for non editable formsections" do
    fields = [Field.new(:name => 'my_field', :display_name => 'My Field', :type=>"text_field", :visible => true)]
    form_section = FormSection.new "name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => fields

    assign(:form_section, form_section)
    render

    document = Nokogiri::HTML(rendered)
    document.css("#fields_my_field").should be_empty
    document.css(".enabledStatus").should be_empty
    document.css(".formSectionButtons").should be_empty
  end

  it "should not have Down or Up UI elements for uneditable field" do
    fields = [{:name=>"topfield"}, {:name=>"field", :editable=>false},{:name=>"bottomfield"}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo"

    assign(:form_section, form_section)
    render

    document = Nokogiri::HTML(rendered)

    document.css("#fieldRow .up-link").should be_empty
    document.css("#fieldRow .down-link").should be_empty
  end

  it "should be blank if the options is empty" do
    fields = [{:option_strings_text=>""}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo"
    assign(:form_section, form_section)
    render

    document = Nokogiri::HTML(rendered)

    document.css("#form_sections tbody tr td:nth-child(3)").inner_text.should be_empty
  end

  it "should have the options if the options strings text is not empty" do
    fields = [{:option_strings_text=>"1", :display_name => "Display Name"}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo", :name => "Form Section"
    assign(:form_section, form_section)
    #There is a test field.new? in the template,
    #so correct thing is save the form section before render
    form_section.save
    render

    document = Nokogiri::HTML(rendered)

    document.css("#form_sections tbody tr td:nth-child(3)").inner_text.should =='["1"]'
  end

  it "should not have edit or delete or enable UI elements for uneditable fields" do
    fields = [{:name=>"topfield"}, {:name=>"field", :editable=>false},{:name=>"bottomfield"}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo"

    assign(:form_section, form_section)
    render

    document = Nokogiri::HTML(rendered)

    document.css("#field_Delete").should be_empty
    document.css("#field_edit").should be_empty
    document.css("#fields_field").should be_empty
  end

  it "should display forms in system language when user language is different" do
    I18n.default_locale = :fr
    user = double('user', :has_permission? => true, :user_name => 'name', :locale => :en)
    controller.stub(:current_user).and_return(user)
    # view.stub(:current_user).and_return(@user)

    form_section = FormSection.new "name_fr" => "Basic Details French", "name_en" => "Basic Details English",
        "enabled"=> "true", "description_fr"=>"Blah blah French", "description_en"=>"Blah blah", "help_text_fr" => "help me French",
        "help_text_en" => "help me English", "order"=>"10", "unique_id"=> "basic_details", :editable => "false"
    assign(:form_section, form_section)
    render

    page = Nokogiri::HTML(rendered)

    page.css("#form_section_name").first["value"].should == "Basic Details French"
    page.css("#form_section_description").first["value"].should == "Blah blah French"
    page.css("#form_section_help_text").first["value"].should == "help me French"

    # Hpricot(rendered).at(".results-count").at("p").inner_html.should == "1 record found"
  end

end
