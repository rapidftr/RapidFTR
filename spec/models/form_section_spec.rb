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

  describe "repository methods" do
    after { FormSection.all.each &:destroy }

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

  describe "add_checkbox_field_to_formsection" do

    it "adds the checkbox to the formsection" do
      field = Field.new_check_box("name")
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSection.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end

    it "saves the formsection with checkbox field" do
      field = Field.new_check_box("name")
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
    it "should give the formsection a new unique id based on the name" do
      form_section_name = "basic details"
      create_should_be_called_with :unique_id, "basic_details"
      FormSection.create_new_custom form_section_name
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
    it "should populate the enabled status" do
      create_should_be_called_with :enabled, true
      FormSection.create_new_custom "basic", "form_section_description", true
      create_should_be_called_with :enabled, false
      FormSection.create_new_custom "basic", "form_section_description", false
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
      valid_attributes = {:name => same_name, :unique_id => same_name.dehumanize, :description => '', :enabled => true}
      FormSection.create! valid_attributes.dup
      form_section = FormSection.new valid_attributes.dup
      form_section.should_not be_valid
      form_section.errors.on(:name).should be_present
    end
    it "should not trip the unique name validation on self" do
      form_section = FormSection.new(:name => 'Unique Name', :unique_id => 'unique_name')
      form_section.create!
      form_section.should be_valid
    end
  end

  describe "disable_fields" do
    it "should set all given fields to disabled" do
      field_blub = Field.new :name => 'blub', :enabled => true
      field_bla = Field.new :name => 'bla', :enabled => true
      form_section = FormSection.new :fields => [field_blub, field_bla]

      form_section.disable_fields([field_bla.name])
      field_blub.should be_enabled
      field_bla.should_not be_enabled
    end
  end

  describe "enable_fields" do
    it "should set all given fields to enabled" do
      field_one = Field.new :name => 'one', :enabled => false
      field_two = Field.new :name => 'two', :enabled => false
      form_section = FormSection.new :fields => [field_one, field_two]

      form_section.enable_fields([field_two.name])
      field_one.should_not be_enabled
      field_two.should be_enabled
    end
  end
end
