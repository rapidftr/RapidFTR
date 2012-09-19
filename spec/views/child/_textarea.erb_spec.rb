require 'spec_helper'

describe "children/_textarea.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    textarea = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'textarea',
    :help_text => "This is my help text"

    render :partial => 'children/textarea.html.erb', :locals => { :textarea => textarea}
    rendered.should be_include("<img class=\"tool-tip-icon vtip\"")
  end

  it "should not include image for tooltip when help text not exists" do
    textarea = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'textarea'

    render :partial => 'children/textarea.html.erb', :locals => { :textarea => textarea}

    rendered.should_not be_include("<img class=\"tool-tip-icon vtip\"")
  end

end
