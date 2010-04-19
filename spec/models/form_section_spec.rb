require "spec_helper"

  def mock_formsection(stubs={})
    stubs.reverse_merge!(:fields=>[], :save=>true, :has_field=>false)
    @mock_formsection ||= mock_model(FormSectionDefinition, stubs)
  end

def new_field(fields = {})
  fields.reverse_merge!(:name=>random_string)
  FieldDefinition.new fields
end

def random_string(length=10)
  #hmmm
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    password = ''
    length.times { password << chars[rand(chars.size)] }
    password
end


describe FormSectionDefinition do
  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSectionDefinition.new
      unique_id = "fred"
      FormSectionDefinition.stub(:by_unique_id).with(:key=>unique_id).and_return([expected])
      FormSectionDefinition.get_by_unique_id(unique_id).should == expected
    end
  end
  describe "has_field" do
    it "should be true if the formsection has a field with that name" do
      field_name = "the_field"
      formsection = FormSectionDefinition.new :fields=>[new_field :name=>field_name]
      formsection.has_field(field_name).should == true
    end
    it "should be true if the formsection does not have a field with that name" do
      field_name = "the_field"
      formsection = FormSectionDefinition.new :fields=>[new_field]
      formsection.has_field(field_name).should == false
    end
  end
  describe "add_field_to_formsection" do
    it "adds the field to the formsection" do
      field = FieldDefinition.new
      formsection = mock_formsection :fields => [new_field(), new_field()], :save=>true
      FormSectionDefinition.add_field_to_formsection formsection, field
      formsection.fields.length.should == 3
      formsection.fields[2].should == field
    end
    it "saves the formsection" do
      field = FieldDefinition.new
      formsection = mock_formsection
      formsection.should_receive(:save)    
      FormSectionDefinition.add_field_to_formsection formsection, field
    end
    it "raises an error if a field with that name already exists on the form section"  do
      field = new_field :name=>'field_one'
      formsection = FormSectionDefinition.new :fields=>[new_field :name=>'field_one']
      lambda {FormSectionDefinition.add_field_to_formsection formsection,field}.should raise_error
    end
  end
end