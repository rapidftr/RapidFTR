require 'spec_helper'

describe "children/_textarea.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    textarea = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'textarea',
    :help_text => "This is my help text"
    
    render :locals => { :textarea => textarea}
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    textarea = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'textarea'
    
    render :locals => { :textarea => textarea}
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")

  end
  
end
