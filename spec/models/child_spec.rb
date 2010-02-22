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


  it "should create a unique id based on the last known location and the user name" do
    child = Child.new({'last_known_location'=>'london'})
    UUIDTools::UUID.stub("random_create").and_return(12345)
    child.create_unique_id("george")
    child["unique_id"].should == "georgelon12345"
  end

  it "should use a default location if last known location is empty" do
    child = Child.new({'last_known_location'=>nil})
    UUIDTools::UUID.stub("random_create").and_return(12345)
    child.create_unique_id("george")
    child["unique_id"].should == "georgexxx12345"
  end


  it "should downcase the last known location of a child before generating the unique id" do
    child = Child.new({'last_known_location'=>'New York'})
    UUIDTools::UUID.stub("random_create").and_return(12345)
    child.create_unique_id("george")
    child["unique_id"].should == "georgenew12345"
  end

  it "should append a five digit random number to the unique child id" do
     child = Child.new({'last_known_location'=>'New York'})
    UUIDTools::UUID.stub("random_create").and_return('12345abcd')
    child.create_unique_id("george")
    child["unique_id"].should == "georgenew12345"
  end


end
  

