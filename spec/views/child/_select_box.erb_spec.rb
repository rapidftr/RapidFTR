require 'spec_helper'

describe "children/_select_box.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    select_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'select_box',
    :option_strings => Array['M', 'F'],
    :help_text => "This is my help text"
    
    render :locals => { :select_box => select_box}
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    select_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'select_box',
    :option_strings => Array['M', 'F']
    
    render :locals => { :select_box => select_box}
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")

  end
  
end
