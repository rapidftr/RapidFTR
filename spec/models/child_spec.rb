require 'spec_helper'


describe Child do
  
  before :all do
    CouchRestRails::Tests.setup("child")
  end
  
  after :all do
    CouchRestRails::Tests.teardown("child")
  end
  
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
    child["unique_identifier"].should == "georgelon12345"
  end

  it "should use a default location if last known location is empty" do
    child = Child.new({'last_known_location'=>nil})
    UUIDTools::UUID.stub("random_create").and_return(12345)
    child.create_unique_id("george")
    child["unique_identifier"].should == "georgexxx12345"
  end


  it "should downcase the last known location of a child before generating the unique id" do
    child = Child.new({'last_known_location'=>'New York'})
    UUIDTools::UUID.stub("random_create").and_return(12345)
    child.create_unique_id("george")
    child["unique_identifier"].should == "georgenew12345"
  end

  it "should append a five digit random number to the unique child id" do
    child = Child.new({'last_known_location'=>'New York'})
    UUIDTools::UUID.stub("random_create").and_return('12345abcd')
    child.create_unique_id("george")
    child["unique_identifier"].should == "georgenew12345"
  end

  it "should handle special characters in last known location when creating unique id" do
    child = Child.new({'last_known_location'=>'ÃÄ§Ä·'})
    UUIDTools::UUID.stub("random_create").and_return('12345abcd')
    child.create_unique_id("george")
    child["unique_identifier"].should == "georgeÃÄ12345"
  end
  
  describe "history log" do
    it "should not update history on initial creation of child document" do
      @child = Child.new('last_known_location' => 'New York')
      @child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      @child.save

      @child['histories'].should be_empty
    end
    
    it "should update history with from value on field update" do
      @child = Child.new('last_known_location' => 'New York')
      @child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      @child.save!

      @child['last_known_location'] = 'Philadelphia'
      @child.save!
      
      @child['histories'].first['from'].should == 'New York'
    end
    
    it "should update history with to value on field update" do
      @child = Child.new('last_known_location' => 'New York')
      @child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      @child.save!
    
      @child['last_known_location'] = 'Philadelphia'
      @child.save!
      
      @child['histories'].first['to'].should == 'Philadelphia'
    end
  end  
end
