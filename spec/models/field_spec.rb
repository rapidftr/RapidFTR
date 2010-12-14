require 'spec_helper'

describe "Child record field view model" do

  before :each do
    @field_name = "gender"
    @field = Field.new_radio_button @field_name, ["male", "female"]
  end

  it "converts field name to a HTML tag ID" do
    @field.tag_id.should == "child_#{@field_name}"
  end

  it "converts field name to a HTML tag name" do
    @field.tag_name_attribute.should == "child[#{@field_name}]"
  end

  it "returns the html options tags for a select box with default option '(Select...)'" do
    @field = Field.new_select_box("select_box", ["option 1", "option 2"])
    @field.select_options.should == [["(Select...)", ""], ["option 1", "option 1"], ["option 2", "option 2"]]
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
      other_form = FormSection.new(:name => "test form", :fields => [Field.new(:name => "other test", :display_name => "other test")] )
      other_form.save!
    
      form = FormSection.new
      field = Field.new(:display_name => "test", :name => "other test")
      form.fields << field
    
      field.valid?
      field.errors.on(:display_name).should ==  ["Field already exists on form 'test form'"] 
    end
  end

  describe "save" do
    it "should be enabled" do
      field = Field.new :name => "field", :display_name => "field"
      form = FormSection.new :fields => [field], :name => "test_form"

      form.save!
      field.should be_enabled
    end
  end
end
