require 'spec_helper'

describe "children/_audio_upload_box.html.erb", :type => :view do

  it "should show help text when exists" do
    audio_field = Field.new :name => "new field",
                            :display_name => "field name",
                            :type => 'audio_upload_box',
                            :help_text => "This is my help text"

    render :partial => 'children/audio_upload_box', :locals => { :audio_upload_box => audio_field }, :formats => [:html], :handlers => [:erb]

    expect(rendered).to have_tag(".help-text-container")
    expect(rendered).to have_tag(".help-text")
  end

  it "should not show help text when not exists" do
    audio_field = Field.new :name => "new field",
                            :display_name => "field name",
                            :type => 'audio_upload_box'

    render :partial => 'children/audio_upload_box', :locals => { :audio_upload_box => audio_field }, :formats => [:html], :handlers => [:erb]

    expect(rendered).not_to have_tag(".help-text-container")
    expect(rendered).not_to have_tag(".help-text")
  end

end
