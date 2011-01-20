require 'spec_helper'

describe "Child record field view model" do

  before :each do
    @field_name = "gender"
    @field = Field.new :name => "gender", :display_name => @field_name, :option_strings => "male\nfemale", :type => Field::RADIO_BUTTON
  end

  it "converts field name to a HTML tag ID" do
    @field.tag_id.should == "child_#{@field_name}"
  end

  it "converts field name to a HTML tag name" do
    @field.tag_name_attribute.should == "child[#{@field_name}]"
  end

  it "returns the html options tags for a select box with default option '(Select...)'" do
    @field = Field.new :type => Field::SELECT_BOX, :display_name => @field_name, :option_strings_text => "option 1\noption 2"
    @field.select_options.should == [["(Select...)", ""], ["option 1", "option 1"], ["option 2", "option 2"]]
  end
  
  it "should have form type" do
    @field.type.should == "radio_button"
    @field.form_type.should == "multiple_choice"
  end
  
  it "should create options from text" do
    field = Field.new :display_name => "something", :option_strings_text => "tim\nrob"
    field['option_strings_text'].should == nil    
    field['option_strings'].should == ["tim", "rob"]
  end
  
  describe "valid?" do
  
    it "should not allow blank display name" do  
      field = Field.new(:display_name => "")
      field.valid?
      field.errors.on(:display_name).should ==  ["Display name must not be blank"] 
    end
  
    it "should validate unique within form" do  
      form = FormSection.new(:fields => [Field.new(:name => "test", :display_name => "test")] )
      field = Field.new(:display_name => "test", :name => "test")
      form.fields << field
    
      field.valid?
      field.errors.on(:display_name).should ==  ["Field already exists on this form"] 
    end
    
    it "should validate radio button has at least 2 options" do  
      field = Field.new(:display_name => "test", :option_strings => ["test"], :type => Field::RADIO_BUTTON)
    
      field.valid?
      field.errors.on(:option_strings).should ==  ["Field must have at least 2 options"] 
    end
  
    it "should validate select box has at least 2 options" do  
      field = Field.new(:display_name => "test", :option_strings => ["test"], :type => Field::SELECT_BOX)
    
      field.valid?
      field.errors.on(:option_strings).should ==  ["Field must have at least 2 options"] 
    end
    
    it "should validate unique within other forms" do  
      other_form = FormSection.new(:name => "test form", :fields => [Field.new(:name => "other_test", :display_name => "other test")] )
      other_form.save!
    
      form = FormSection.new
      field = Field.new(:display_name => "other test", :name => "other_test")
      form.fields << field
    
      field.valid?
      field.errors.on(:display_name).should ==  ["Field already exists on form 'test form'"] 
    end

    it "should not be valid if starts with * wildcard" do
      field = Field.new(:display_name => "*")
      field.valid?
      field.errors.on(:display_name).should ==  ["Field name must contain only alphanumeric characters,underscore and spaces"]
    end

    it "should not be valid if starts with ~ wildcard" do
      field = Field.new(:display_name => "~asd")
      field.valid?
      field.errors.on(:display_name).should ==  ["Field name must contain only alphanumeric characters,underscore and spaces"]
    end

    it "should not be valid if starts with \\ escape char" do
      field = Field.new(:display_name => "\\")
      field.valid?
      field.errors.on(:display_name).should ==  ["Field name must contain only alphanumeric characters,underscore and spaces"]
    end

    it "should be valid if the field contains _" do
      field = Field.new(:display_name => "a_b")
      field.valid?
      field.errors.on(:display_name).should be_nil
    end

    it "should be valid if the field contains numbers" do
      field = Field.new(:display_name => "as10")
      field.valid?
      field.errors.on(:display_name).should be_nil
    end
  end

  describe "save" do
    it "should be enabled" do
      field = Field.new :name => "field", :display_name => "field", :enabled => "true"
      form = FormSection.new :fields => [field], :name => "test_form"

      form.save!
      field.should be_enabled
    end
  end
end
