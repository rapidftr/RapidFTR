require "spec_helper"

def mock_formsection(stubs={})
  stubs.reverse_merge!(:fields=>[], :save => true, :has_field => false, :editable => true)
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


describe FormSection do
  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSection.new
      unique_id = "fred"
      FormSection.stub(:by_unique_id).with(:key=>unique_id).and_return([expected])
      FormSection.get_by_unique_id(unique_id).should == expected
    end
  end
  
  describe "has_field" do

    it "should be true if the formsection has a field with that name" do
      field_name = "the_field"
      formsection = FormSection.new(:fields=>[new_field(:name=>field_name)])
      formsection.has_field(field_name).should == true
    end

    it "should be true if the formsection does not have a field with that name" do
      field_name = "the_field"
      formsection = FormSection.new(:fields=>[new_field])
      formsection.has_field(field_name).should == false
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
    
    it "raises an error if a field with that name already exists on the form section"  do
      field = new_field :name=>'field_one'
      formsection = FormSection.new :fields=>[new_field(:name=>'field_one')]
      lambda {FormSection.add_field_to_formsection formsection,field}.should raise_error
    end
    
    it "should raise an error if adding a field to a non editable form section" do
      field = new_field :name=>'field_one'
      formsection = FormSection.new :editable => false
      lambda {FormSection.add_field_to_formsection formsection,field}.should raise_error
    end
    
  end
  
  describe "editable" do
    
    it "should be editable by default" do
      formsection = FormSection.new
      formsection.editable?.should be_true
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
      lambda {@formsection.move_up_field "field1"}.should raise_error
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
      lambda {@formsection.move_down_field "field2"}.should raise_error
    end
  end

end