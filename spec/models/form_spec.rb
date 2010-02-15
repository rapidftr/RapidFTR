require "spec"

describe "Form ordering" do

  it "should return form fields in the order they are defined in the Schema" do
    Schema.stub(:keys_in_order).and_return(["name", "age", "origin"])

    form = Form.new({"age" => "27", "name" => "Tom", "origin" => "London"})

    form.keys.should == ["name", "age", "origin"]
  end

  it "should return all fields not found in the schema at the end, in alphabetical order" do
    Schema.stub(:keys_in_order).and_return(["name", "age", "origin"])

    form = Form.new({"no_of_toes" => "10", "favourite_colour" => "Blue", "age" => "27", "name" => "Tom", "origin" => "London"})

    form.keys.should == ["name", "age", "origin", "favourite_colour", "no_of_toes"]
  end
end