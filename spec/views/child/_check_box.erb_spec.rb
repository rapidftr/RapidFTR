require 'spec_helper'

describe "children/_check_box.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "Yes")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    check_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'check_box',
    :help_text => "This is my help text"
    
    render :locals => { :check_box => check_box }
  
    response.should have_tag("img.vtip")
  end

  it "should not include image for tooltip when help text not exists" do
    check_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'check_box'
    
    render :locals => { :check_box => check_box }
  
    response.should_not have_tag("img.vtip")
  end
  
end
