require 'spec_helper'

describe "children/_photo_upload_box.html.erb" do
  before :each do
    @child = Child.new("_id" => "id12345", "name" => "First Last")
    assigns[:child] = @child
  end

  it "should show help text when exists" do
    photo_upload_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'photo_upload_box',
    :help_text => "This is my help text"
    
    render :locals => { :photo_upload_box => photo_upload_box}
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    photo_upload_box = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'photo_upload_box'
    
    render :locals => { :photo_upload_box => photo_upload_box}
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")

  end
  
end
