require 'spec_helper'

describe "children/_photo_upload_box.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last")
    assigns[:child] = @child
  end

  it "should include image for tooltip when help text exists" do
    photo_upload_box = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'photo_upload_box',
    :help_text => "This is my help text"

    render :partial => 'children/photo_upload_box', :locals => { :photo_upload_box => photo_upload_box}, :formats => [:html], :handlers => [:erb]

    rendered.should be_include("<img class=\"tool-tip-icon vtip\"")
  end

  it "should not include image for tooltip when help text not exists" do
    photo_upload_box = Field.new :name => "new field",
    :display_name => "field name",
    :type => 'photo_upload_box'

    render :partial => 'children/photo_upload_box', :locals => { :photo_upload_box => photo_upload_box}, :formats => [:html], :handlers => [:erb]

    rendered.should_not be_include("<img class=\"tool-tip-icon vtip\"")
  end

end
