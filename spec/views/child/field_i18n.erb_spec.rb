require 'spec_helper'

describe 'children/' do
  before :all do
    @old_backend = I18n.backend
    I18n.backend = I18nBackendCouch.new
  end

  after :all do
    I18n.backend = @old_backend
  end

  before :each do
    I18n.backend.class.should == I18nBackendCouch
    @child = Child.new("_id" => "id12345", "name" => "First Last", "new field" => "")
    assigns[:child] = @child
  end

  shared_examples "label translation" do
    it "should be shown" do
      translated_name = "XYZ"
      I18n.backend.store_translations("en", @field.name => translated_name)
      render :partial => "children/#{@field.type}", :object => @field
      rendered.should be_include(translated_name)
      rendered.should_not be_include(@field.display_name)
    end

    it "should not be shown" do
      I18n.backend.store_translations("en", @field.name => nil)
      render :partial => "children/#{@field.type}", :object => @field
      rendered.should be_include(@field.display_name)
    end
  end

  FIELDS = [
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'numeric_field'),
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'text_field'),
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'textarea'),

    # Audio upload and photo upload boxes are using Static labels instead of field.display_name
    # Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'audio_upload_box'),
    # Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'photo_upload_box'),
    
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'date_field'),
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'radio_button', :option_strings => []),
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'select_box', :option_strings => []),
    Field.new(:name => 'new_field', :display_name => 'This is a New Field', :type => 'check_boxes', :option_strings => [])
  ]

  FIELDS.each do |field|
    describe field.type do
      before :each do
        @field = field
      end

      it_should_behave_like "label translation"
    end
  end

end
