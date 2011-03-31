require 'spec_helper'

describe "children/_numeric_field.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    numeric_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'numeric_field',
    :help_text => "This is my help text"
    
    render :locals => { :numeric_field => numeric_field }
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    numeric_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'numeric_field'
    
    render :locals => { :numeric_field => numeric_field }
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")

  end
  
end
