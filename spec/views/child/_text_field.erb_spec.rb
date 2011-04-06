require 'spec_helper'

describe "children/_text_field.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last")
    assigns[:child] = @child
  end
  
  it "should show help text when exists" do
    text_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'text_field',
    :help_text => "This is my help text"
    
    render :locals => { :text_field => text_field }
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    text_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'text_field'
    
    render :locals => { :text_field => text_field }
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")
  end
  
end
