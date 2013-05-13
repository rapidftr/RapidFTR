require 'spec_helper'

describe "children/_radio_button.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "radio button group name")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    radio_button = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'radio_button',
    :option_strings => Array['M', 'F'],
    :help_text => "This is my help text"

    render :partial => 'children/radio_button.html.erb', :locals => { :radio_button => radio_button}

    rendered.should be_include("<img class=\"tool-tip-icon vtip\"")
  end

  it "should not include image for tooltip when help text not exists" do
    radio_button = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'radio_button',
    :option_strings => Array['M', 'F']

    render :partial => 'children/radio_button.html.erb', :locals => { :radio_button => radio_button}

    rendered.should_not be_include("<img class=\"tool-tip-icon vtip\"")
  end

end
