require 'spec_helper'

describe 'shared/', :type => :view do
  before :all do
    @old_backend = I18n.backend
    I18n.backend = I18nBackendCouch.new
  end

  after :all do
    I18n.backend = @old_backend
  end

  before :each do
    expect(I18n.backend.class).to eq(I18nBackendCouch)
    @child = Child.new('_id' => 'id12345', 'name' => 'First Last', 'new field' => '')
    assigns[:child] = @child
  end

  shared_examples 'label translation' do
    it 'should be shown' do
      translated_name = 'XYZ'
      I18n.backend.store_translations('en', @field.name => translated_name)
      render :partial => "shared/#{@field.type}", :object => @field, :locals => {:model => Child.new}
      expect(rendered).to be_include(translated_name)
      expect(rendered).not_to be_include(@field.display_name)
    end

    it 'should not be shown' do
      I18n.backend.store_translations('en', @field.name => nil)
      render :partial => "shared/#{@field.type}", :object => @field, :locals => {:model => Child.new}
      expect(rendered).to be_include(@field.display_name)
    end
  end

  FIELDS = [
    FactoryGirl.build(:numeric_field, :name => 'new_field', :display_name => 'This is a New Field'),
    FactoryGirl.build(:text_field, :name => 'new_field', :display_name => 'This is a New Field'),
    FactoryGirl.build(:text_area_field, :name => 'new_field', :display_name => 'This is a New Field'),

    # Audio upload and photo upload boxes are using Static labels instead of field.display_name
    # FactoryGirl.build(:audio_field, name: 'new_field', display_name: 'This is a New Field'),
    # FactoryGirl.build(:photo_field, name: 'new_field', display_name: 'This is a New Field'),

    FactoryGirl.build(:date_field, :name => 'new_field', :display_name => 'This is a New Field'),
    FactoryGirl.build(:radio_button_field, :name => 'new_field', :display_name => 'This is a New Field', :option_strings => []),
    FactoryGirl.build(:select_box_field, :name => 'new_field', :display_name => 'This is a New Field', :option_strings => []),
    FactoryGirl.build(:check_boxes_field, :name => 'new_field', :display_name => 'This is a New Field', :option_strings => [])
  ]

  FIELDS.each do |field|
    describe field.type do
      before :each do
        @field = field
      end

      it_should_behave_like 'label translation'
    end
  end

end
