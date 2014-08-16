require 'spec_helper'

describe "children/_check_boxes.html.erb", :type => :view do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "Yes")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    check_boxes = Field.new :name => "new field",
                            :display_name => "field name",
                            :type => Field::CHECK_BOXES,
                            :help_text => "This is my help text",
                            :option_strings => ["FOO", "BAR"]

    render :partial => 'children/check_boxes', :locals => { :check_boxes => check_boxes, :child => @child }, :formats => [:html], :handlers => [:erb]

    expect(rendered).to have_tag("img.vtip")
  end

  it "should not include image for tooltip when help text does not exist" do
    check_boxes = Field.new :name => "new field",
                            :display_name => "field name",
                            :type => Field::CHECK_BOXES,
                            :option_strings => ["FOO", "BAR"]

    render :partial => 'children/check_boxes', :locals => { :check_boxes => check_boxes, :child => @child }, :formats => [:html], :handlers => [:erb]

    expect(rendered).not_to have_tag("img.vtip")
  end

end
