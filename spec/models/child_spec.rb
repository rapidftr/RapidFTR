require 'spec_helper'


describe Child do

  describe "Updating a Child's properties from another Child object" do
    it "replaces existing child properties with non-nil properties from the updated Child" do
      child = Child.new "name" => "Dave", "age" => "28", "origin" => "Croydon", "last_known_location" => "London"
      updated_child = Child.new "name" => "Dave", "age" => "35", "origin" => nil
      child.update_properties_from updated_child, "some_user"
      child['age'].should == "35"
      child['name'].should == "Dave"
      child['origin'].should == "Croydon"
      child['last_known_location'].should == "London"
    end
    
    it "should populate last_updated_by field with the user_name who is updating" do
      child = Child.new
      child.update_properties_from Child.new, "jdoe"
      child['last_updated_by'].should == 'jdoe'
    end
    
    it "should populate last_updated_at field with the time of the update" do
      current_time = Time.now
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_from Child.new, "jdoe"
      child['last_updated_at'].should == current_time.strftime("%m/%d/%y %H:%M")
    end
  end

  describe "validating an existing child record" do
    
    photo = File.new("features/resources/jorge.jpg")
    def photo.content_type
      "image/jpg"
    end
  
    def photo.original_path
      "features/resources/jorge.jpg"
    end
    
    child = Child.new
    child['last_known_location'] = "location"
    child.photo = photo
  
    child.save.should == true
  
    loaded_child = Child.get(child.id)
    loaded_child.save().should == true
  end

  describe "new_with_user_name" do    
    it "should create regular child fields" do
      child = Child.new_with_user_name('jdoe', 'last_known_location' => 'London', 'age' => '6')
      child['last_known_location'].should == 'London'
      child['age'].should == '6'
    end
    
    it "should create a unique id" do
      UUIDTools::UUID.stub("random_create").and_return(12345)
      child = Child.new_with_user_name('jdoe', 'last_known_location' => 'London')
      child['unique_identifier'].should == "jdoelon12345"
    end
    
    it "should create a created_by field with the user name" do
      child = Child.new_with_user_name('jdoe', 'some_field' => 'some_value')
      child['created_by'].should == 'jdoe'
    end
    
    it "should create a created_at field with time of creation" do
      current_time = Time.now
      Time.stub!(:now).and_return current_time
      child = Child.new_with_user_name('some_user', 'some_field' => 'some_value')
      child['created_at'].should == current_time.strftime("%m/%d/%y %H:%M")
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
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
    
      child['histories'].should be_empty
    end
    
    it "should update history with 'from' value on last_known_location update" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['last_known_location'] = 'Philadelphia'
      child.save!
    
      changes = child['histories'].first['changes']
      changes['last_known_location']['from'].should == 'New York'
    end
    
    it "should update history with 'to' value on last_known_location update" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['last_known_location'] = 'Philadelphia'
      child.save!
    
      changes = child['histories'].first['changes']
      changes['last_known_location']['to'].should == 'Philadelphia'
    end
    
    it "should update history with 'from' value on age update" do
      child = Child.new('age' => '8', 'last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['age'] = '6'
      child.save!
    
      changes = child['histories'].first['changes']
      changes['age']['from'].should == '8'
    end
    
    it "should update history with 'to' value on age update" do
      child = Child.new('age' => '8', 'last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['age'] = '6'
      child.save!
    
      changes = child['histories'].first['changes']
      changes['age']['to'].should == '6'
    end
    
    it "should update history with a combined history record when multiple fields are updated" do
      child = Child.new('age' => '8', 'last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['age'] = '6'
      child['last_known_location'] = 'Philadelphia'
      child.save!
      
      child['histories'].size.should == 1
      changes = child['histories'].first['changes']
      changes['age']['from'].should == '8'
      changes['age']['to'].should == '6'
      changes['last_known_location']['from'].should == 'New York'
      changes['last_known_location']['to'].should == 'Philadelphia'
    end
    
    it "should not record anything in the history if a save occured with no changes" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      loaded_child = Child.get(child.id)
      loaded_child.save!
      
      loaded_child['histories'].should be_empty
    end
    
    it "should not record empty string in the history if only change was spaces" do
      child = Child.new('origin' => '', 'last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!

      child['origin'] = '    '
      child.save!
      
      child['histories'].should be_empty
    end
    
    it "should not record history on populated field if only change was spaces" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!

      child['last_known_location'] = ' New York   '
      child.save!
      
      child['histories'].should be_empty
    end
    
    it "should record history for newly populated field that previously was null" do
      # gender is the only field right now that is allowed to be nil when creating child document
      child = Child.new('gender' => nil, 'last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!

      child['gender'] = 'Male'
      child.save!
      
      child['histories'].first['changes']['gender']['from'].should be_nil
      child['histories'].first['changes']['gender']['to'].should == 'Male'
    end
        
    it "should update history with username from last_updated_by" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['last_known_location'] = 'Philadelphia'
      child['last_updated_by'] = 'some_user'
      child.save!
      
      child['histories'].first['user_name'].should == 'some_user'      
    end

    it "should update history with the datetime from last_updated_at" do
      child = Child.new('last_known_location' => 'New York')
      child.instance_variable_set(:'@file_name', 'some_file.jpg') # to pass photo validation
      child.save!
      
      child['last_known_location'] = 'Philadelphia'
      child['last_updated_at'] = 'some_time'
      child.save!
      
      child['histories'].first['datetime'].should == 'some_time'
    end
  end
end
