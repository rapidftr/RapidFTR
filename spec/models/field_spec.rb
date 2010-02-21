require "spec"

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

end
