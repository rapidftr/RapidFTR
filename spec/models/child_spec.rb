require 'spec_helper'

describe Child do

  describe "Updating a Child's properties from another Child object" do

    it "replaces existing child properties with non-blank properties from the updated Child" do
      child = Child.new "name" => "Dave", "age" => "28", "origin" => "Croydon"
      updated_child = Child.new "name" => "Dave", "age" => "35", "origin" => ""
      child.update_properties_from updated_child
      child['age'].should == "35"
      child['name'].should == "Dave"
      child['origin'].should == "Croydon"
    end
  end
  
end
