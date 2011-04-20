require 'spec_helper'
require 'nokogiri'

describe "form_section/edit.html.erb" do
  it "should not allow to edit name for permanently enabled formsections" do
    fields = [Field.new :name => 'my_field', :display_name => 'My Field', :enabled => true]
    form_section = FormSection.new "name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => fields, :perm_enabled => true

    assigns[:form_section] = form_section
    render

    document = Nokogiri::HTML(response.body)
    document.css("#form_section_name").should be_empty
  end
  it "should not allow to enable/disable fields for non editable formsections" do
    fields = [Field.new :name => 'my_field', :display_name => 'My Field', :enabled => true]
    form_section = FormSection.new "name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => fields

    assigns[:form_section] = form_section
    render

    document = Nokogiri::HTML(response.body)
    document.css("#fields_my_field").should be_empty
    document.css(".enabledStatus").should be_empty
    document.css(".formSectionButtons").should be_empty
  end

  it "should not have Up UI elements for first field item when in edit mode" do
    fields = [{:name=>"one"},{:name=>"two"}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo"

    assigns[:form_section] = form_section
    render

    document = Nokogiri::HTML(response.body)

    document.css("#oneRow .up-link").should be_empty
    document.css("#twoRow .up-link").should_not be_empty
  end
  it "should not have Down UI elements for last field item when in edit mode" do
    fields = [{:name=>"one"},{:name=>"two"}]
    form_section = FormSection.new :fields => fields, :unique_id=>"foo"

    form_section = FormSection.new "name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "true", :fields => fields

    assigns[:form_section] = form_section
    render

    document = Nokogiri::HTML(response.body)

    document.css("#twoRow .down-link").should be_empty
    document.css("#oneRow .down-link").should_not be_empty
  end
end
