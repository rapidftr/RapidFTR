require 'spec_helper'

describe "children/_date_field.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    date_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'date_field',
    :help_text => "This is my help text"
    
    render :locals => { :date_field => date_field }
  
    response.should have_tag("img.vtip")

  end

  it "should not include image for tooltip when help text not exists" do
    date_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'date_field'
    
    render :locals => { :date_field => date_field }
  
    response.should_not have_tag("img.vtip")

  end
  
end
