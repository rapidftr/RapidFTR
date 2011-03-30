require 'spec_helper'

describe "children/_audio_upload_box.html.erb" do
  
  it "should show help text when exists" do
    audio_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'audio_upload_box',
    :help_text => "This is my help text"
    
    render :locals => { :audio_upload_box => audio_field }
  
    response.should have_tag(".help-text-container")
    response.should have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    audio_field = Field.new :name => "new field", 
    :display_name => "field name",
    :type => 'audio_upload_box'
    
    render :locals => { :audio_upload_box => audio_field }
  
    response.should_not have_tag(".help-text-container")
    response.should_not have_tag(".help-text")
  end
  
end
