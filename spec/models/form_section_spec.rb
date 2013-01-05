# -*- coding: utf-8 -*-
require 'spec_helper'

describe FormSection do

  def mock_formsection(stubs={})
    stubs.reverse_merge!(:fields=>[], :save => true, :editable => true)
    @mock_formsection ||= mock_model(FormSection, stubs)
  end

  def new_field(fields = {})
    fields.reverse_merge!(:name=>random_string)
    Field.new fields
  end

  def random_string(length=10)
    #hmmm
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    password = ''
    length.times { password << chars[rand(chars.size)] }
    password
  end

  def create_should_be_called_with (name, value)
    FormSection.should_receive(:create!) { |form_section_hash|
      form_section_hash[name].should == value
    }
  end

  it "should return all the searchable fields" do
    text_field = Field.new(:name => "text_field", :type => Field::TEXT_FIELD)
    text_area = Field.new(:name => "text_area", :type => Field::TEXT_AREA)
    select_box = Field.new(:name => "select_box", :type => Field::SELECT_BOX)
    radio_button = Field.new(:name => "radio_button", :type => Field::RADIO_BUTTON)
    f = FormSection.new(:fields => [text_field, text_area, select_box, radio_button])
    f.all_searchable_fields.should == [text_field, text_area, select_box]
  end

  describe '#unique_id' do
    it "should be generated when not provided" do
      f = FormSection.new
      f.unique_id.should_not be_empty
    end

    it "should not be generated when provided" do
      f = FormSection.new :unique_id => 'test_form'
      f.unique_id.should == 'test_form'
    end

    it "should not allow duplic
    ate unique ids" do
      FormSection.new(:unique_id => "test", :name => "test").save!

      expect {
        FormSection.new(:unique_id => "test").save!
      }.to raise_error

      expect {
        FormSection.get_by_unique_id("test").save!
      }.to_not raise_error
    end
  end

  describe "repository methods" do
    before { FormSection.all.each &:destroy }

    describe "enabled_by_order" do
      it "should bring back sections in order" do
        second = FormSection.create! :name => 'Second', :order => 2, :unique_id => 'second'
        first = FormSection.create! :name => 'First', :order => 1, :unique_id => 'first'
        third = FormSection.create! :name => 'Third', :order => 3, :unique_id => 'third'
        FormSection.enabled_by_order.map(&:name).should == %w( First Second Third )
      end

      it "should exclude disabled sections" do
        expected = FormSection.create! :name => 'Good', :order => 1, :unique_id => 'good'
        unwanted = FormSection.create! :name => 'Bad', :order => 2, :unique_id => 'bad', :enabled => false
        FormSection.enabled_by_order.map(&:name).should == %w(Good)
      end
    end

    describe "enabled_by_order_without_disabled_fields" do
      it "should exclude disabled fields" do
        enabled = Field.new(:name => "enabled", :type => "text_field", :display_name => "Enabled")
        disabled = Field.new(:name => "disabled", :type => "text_field", :display_name => "Disabled", :visible => false)

        section = FormSection.new :name => 'section', :order => 1, :unique_id => 'section'
        section.fields = [disabled, enabled]
        section.save!

        FormSection.enabled_by_order_without_disabled_fields.first.fields.should == [enabled]
      end
    end
  end

  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSection.new
      unique_id = "fred"
      FormSection.stub(:by_unique_id).with(:key=>unique_id).and_return([expected])
      FormSection.get_by_unique_id(unique_id).should == expected
    end

    it "should save fields" do
      section = FormSection.new :name => 'somename', :unique_id => "someform"
      section.save!

      section.fields = [Field.new(:name => "a field", :type => "text_field", :display_name => "A Field")]
      section.save!

      field = section.fields.first
      field.name = "kev"
      section.save!

      section = FormSection.get_by_unique_id("someform")
      section.name.should == 'somename'
    end

  end

  describe "add_field_to_formsection" do

    it "adds the field to the formsection" do
      field = Field.new_text_field("name")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection" do
      field = Field.new_text_field("name")
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

    it "should raise an error if adding a field to a non editable form section" do
      field = new_field :name=>'field_one'
      formsection = FormSection.new :editable => false
      lambda { FormSection.add_field_to_formsection formsection, field }.should raise_error
    end

  end


  describe "add_textarea_field_to_formsection" do

    it "adds the textarea to the formsection" do
      field = Field.new_textarea("name")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection with textarea field" do
      field = Field.new_textarea("name")
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "add_select_drop_down_field_to_formsection" do

    it "adds the select drop down to the formsection" do
      field = Field.new_select_box("name", "some")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection with select drop down field" do
      field = Field.new_select_box("name", "some")
      formsection = mock_formsection
      formsection.should_receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "editable" do

    it "should be editable by default" do
      formsection = FormSection.new
      formsection.editable?.should be_true
    end

  end

  describe "perm_enabled" do

    it "should not be perm_enabled by default" do
      formsection = FormSection.new
      formsection.perm_enabled?.should be_false
    end

    it "should be perm_enabled when set" do
      formsection = FormSection.new(:perm_enabled => true)
      formsection.perm_enabled?.should be_true
    end
  end

  describe "delete_field" do
    it "should delete editable fields" do
      @field = new_field(:name=>"field3")
      form_section = FormSection.new :fields=>[@field]
      form_section.delete_field(@field.name)
      form_section.fields.should be_empty
    end

    it "should not delete uneditable fields" do
      @field = new_field(:name=>"field3", :editable => false)
      form_section = FormSection.new :fields=>[@field]
      lambda {form_section.delete_field(@field.name)}.should raise_error("Uneditable field cannot be deleted")
    end
  end

  describe "move_field" do
    it "should not allow uneditable field to be moved" do
      @field = new_field(:name=>"field3", :editable => false)
      form_section = FormSection.new :fields=>[@field]
      lambda {form_section.move_field(@field, 1)}.should raise_error("Uneditable field cannot be moved")
    end
  end

  describe "move_up_field" do
    before :each do
      @field2 = new_field(:name=>"field2")
      @field1 = new_field(:name=>"field1")
      @formsection = FormSection.new :fields=>[@field1, @field2]
    end

    it "should move the field up" do
      @formsection.move_up_field("field2")
      @formsection.fields[0].should == @field2
      @formsection.fields[1].should == @field1
    end

    it "saves the formsection" do
      @formsection.should_receive(:save)
      @formsection.move_up_field "field2"
    end

    it "throws exception if you try to move something up that is already first" do
      lambda { @formsection.move_up_field "field1" }.should raise_error
    end
  end

  describe "move_down_field" do
    before :each do
      @field2 = new_field(:name=>"field2")
      @field1 = new_field(:name=>"field1")
      @formsection = FormSection.new :fields=>[@field1, @field2]
    end

    it "should move the field down" do
      @formsection.move_down_field("field1")

      @formsection.fields[0].should == @field2
      @formsection.fields[1].should == @field1
    end

    it "saves the formsection" do
      @formsection.should_receive(:save)
      @formsection.move_down_field "field1"
    end
    it "throws exception if you try to move something down that is already last" do
      lambda { @formsection.move_down_field "field2" }.should raise_error
    end
  end

  describe "create_new_custom" do
    before :each do
      FormSection.stub(:all).and_return([])
    end
    it "should create a new form section" do
      FormSection.should_receive(:create!)
      FormSection.create_new_custom "basic"
    end
    it "should populate the name" do
      form_section_name = "basic details"
      create_should_be_called_with :name, "basic details"
      FormSection.create_new_custom form_section_name
    end
    it "should populate the description" do
      form_section_description = "info about basic details"
      create_should_be_called_with :description, "info about basic details"
      FormSection.create_new_custom "basic", form_section_description
    end
    it "should populate the help text" do
      create_should_be_called_with :help_text, "help text about basic details"
      FormSection.create_new_custom "basic", "description", "help text about basic details"
    end
    it "should populate the enabled status" do
      form_section_description = "form_section_description"
      form_section_help_text = "help text about basic details"
      create_should_be_called_with :enabled, true
      FormSection.create_new_custom "basic", form_section_description, form_section_help_text, true
      create_should_be_called_with :enabled, false
      FormSection.create_new_custom "basic", form_section_description, form_section_help_text, false
    end
    it "should set the order to one plus maximum order value" do
      FormSection.stub(:all).and_return([FormSection.new(:order=>20), FormSection.new(:order=>10), FormSection.new(:order=>40)])
      create_should_be_called_with :order, 41
      FormSection.create_new_custom "basic"
    end
    it "should set editable to true" do
      create_should_be_called_with :editable, true
      FormSection.create_new_custom "basic"
    end
    it "should return the created form section" do
      form_section = FormSection.new
      FormSection.stub(:create!).and_return(form_section)
      result = FormSection.create_new_custom "basic"
      result.should == form_section
    end
  end

  describe "valid?" do
    it "should validate name is filled in" do
      form_section = FormSection.new()
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end

    it "should validate name is alpha_num" do
      form_section = FormSection.new(:name=>"££ss")
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end

    it "should validate name is unique" do
      same_name = 'Same Name'
      valid_attributes = {:name => same_name, :unique_id => same_name.dehumanize, :description => '', :enabled => true, :order => 0}
      FormSection.create! valid_attributes.dup
      form_section = FormSection.new valid_attributes.dup
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
      form_section.errors.on(:unique_id).should be_present
    end

    it "should not trip the unique name validation on self" do
      form_section = FormSection.new(:name => 'Unique Name', :unique_id => 'unique_name')
      form_section.create!
    end
  end

  describe "disable_fields" do
    it "should set all given fields to disabled" do
      field_blub = Field.new :name => 'blub', :visible => true
      field_bla = Field.new :name => 'bla', :visible => true
      form_section = FormSection.new :fields => [field_blub, field_bla]

      form_section.disable_fields([field_bla.name])
      field_blub.should be_visible
      field_bla.should_not be_visible
    end
  end

  describe "enable_fields" do
    it "should set all given fields to enabled" do
      field_one = Field.new :name => 'one', :visible => false
      field_two = Field.new :name => 'two', :visible => false
      form_section = FormSection.new :fields => [field_one, field_two]

      form_section.enable_fields([field_two.name])
      field_one.should_not be_visible
      field_two.should be_visible
    end
  end

  describe "highlighted_fields" do
    describe "get highlighted fields" do
      before :each do
        high_attr = [{ :order => "1", :highlighted => true }, { :order => "2", :highlighted => true }, { :order => "10", :highlighted => true }]
        @high_fields = [ Field.new(:name => "h1", :highlight_information => high_attr[0]),
                         Field.new(:name => "h2", :highlight_information => high_attr[1]),
                         Field.new(:name => "h3", :highlight_information => high_attr[2]) ]
        field = Field.new :name => "regular_field"
        form_section1 = FormSection.new( :name => "Highlight Form1", :fields => [@high_fields[0], @high_fields[2], field] )
        form_section2 = FormSection.new( :name => "Highlight Form2", :fields => [@high_fields[1]] )
        FormSection.stub(:all).and_return([form_section1, form_section2])
      end

      it "should get fields that have highlight information" do
        highlighted_fields = FormSection.highlighted_fields
        highlighted_fields.size.should == @high_fields.size
        highlighted_fields.map do |field| field.highlight_information end.should
          include @high_fields.map do |field| field.highlight_information end
      end

      it "should sort the highlighted fields by highlight order" do
        sorted_highlighted_fields = FormSection.sorted_highlighted_fields
        sorted_highlighted_fields.map do |field| field.highlight_information.order end.should ==
          @high_fields.map do |field| field.highlight_information.order end
      end
    end

    describe "highlighted fields" do

      it "should update field as highlighted" do
        attrs = { :field_name => "h1", :form_id => "highlight_form" }
        existing_field = Field.new :name => attrs[:field_name]
        form = FormSection.new(:name => "Some Form",
                               :unique_id => attrs[:form_id],
                               :fields => [existing_field])
        FormSection.stub(:all).and_return([form])
        form.update_field_as_highlighted attrs[:field_name]
        existing_field.highlight_information.order.should == 1
        existing_field.is_highlighted?.should be_true
      end

      it "should increment order of the field to be highlighted" do
        attrs = { :field_name => "existing_field", :form_id => "highlight_form"}
        existing_field = Field.new :name => attrs[:field_name]
        existing_highlighted_field = Field.new :name => "highlighted_field"
        existing_highlighted_field.highlight_with_order 3
        form = FormSection.new(:name => "Some Form",
                               :unique_id => attrs[:form_id],
                               :fields => [existing_field, existing_highlighted_field])
        FormSection.stub(:all).and_return([form])
        form.update_field_as_highlighted attrs[:field_name]
        existing_field.is_highlighted?.should be_true
        existing_field.highlight_information.order.should == 4
      end

      it "should un-highlight a field" do
        existing_highlighted_field = Field.new :name => "highlighted_field"
        existing_highlighted_field.highlight_with_order 1
        form = FormSection.new(:name => "Some Form", :unique_id => "form_id",
                               :fields => [existing_highlighted_field])
        FormSection.stub(:all).and_return([form])
        form.remove_field_as_highlighted existing_highlighted_field.name
        existing_highlighted_field.is_highlighted?.should be_false
      end
    end
  end
end
