require 'spec_helper'
require 'nokogiri'

describe "advanced_search/index.html.erb" do
  it "should not show disabled fields" do
    fields = [(Field.new :name => 'my_field', :display_name => 'My Field', :visible => true, :type => Field::TEXT_FIELD),
             (Field.new :name => 'my_hidden_field', :display_name => 'My Hidden Field', :visible=> false, :type => Field::TEXT_FIELD)]
    form_sections = [FormSection.new "name" => "Basic Details", "enabled"=> "true", "description"=>"Blah blah", "order"=>"10", "unique_id"=> "basic_details", :editable => "false", :fields => fields]
    assigns[:forms] = form_sections
    render
    document = Nokogiri::HTML(response.body)
    document.css(".field").count.should == 1
  end
end

