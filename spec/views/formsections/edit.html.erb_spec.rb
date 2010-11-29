require 'spec_helper'
require 'nokogiri'

describe "form_section/edit.html.erb" do
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
end