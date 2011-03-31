require 'spec_helper'

describe "children/_radio_button.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "radio button group name")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    radio_button = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'radio_button',
    :option_strings => Array['M', 'F'],
    :help_text => "This is my help text"
    
    render :locals => { :radio_button => radio_button}
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    radio_button = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'radio_button',
    :option_strings => Array['M', 'F']


    
    render :locals => { :radio_button => radio_button}
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")

  end
  
end
