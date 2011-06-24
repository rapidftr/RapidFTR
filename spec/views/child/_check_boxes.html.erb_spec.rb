require 'spec_helper'

describe "children/_check_boxes.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "Yes")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    check_boxes = Field.new :name => "new field", 
    :display_name => "field name",
    :type => Field::CHECK_BOXES,
    :help_text => "This is my help text",
    :option_strings => ["FOO", "BAR"]
	 	
    render :locals => { :check_boxes => check_boxes, :child => @child }
  
    response.should have_tag(".help-text-checkboxes")
  end

  it "should not show help text when not exists" do
    check_boxes = Field.new :name => "new field", 
    :display_name => "field name",
    :type => Field::CHECK_BOXES,
		:option_strings => ["FOO", "BAR"]
    
    render :locals => { :check_boxes => check_boxes, :child => @child }
  
    response.should_not have_tag(".help-text-checkboxes")
  end
  
end
