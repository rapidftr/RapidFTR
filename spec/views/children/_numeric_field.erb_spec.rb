require 'spec_helper'

describe "children/_numeric_field.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text when exists" do
    numeric_field = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'numeric_field',
    :help_text => "This is my help text"

    render :partial => 'children/numeric_field.html.erb', :locals => { :numeric_field => numeric_field }

    rendered.should be_include("<img class=\"tool-tip-icon vtip\"")
  end

  it "should not include image for tooltip when help text not exists" do
    numeric_field = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'numeric_field'

    render :partial => 'children/numeric_field.html.erb', :locals => { :numeric_field => numeric_field }

    rendered.should_not be_include("<img class=\"tool-tip-icon vtip\"")
  end

end
