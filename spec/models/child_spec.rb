require 'spec_helper'


describe Child do

  describe "update_properties_with_user_name" do
    it "should replace old properties with updated ones" do
      child = Child.new("name" => "Dave", "age" => "28", "last_known_location" => "London")
      new_properties = {"name" => "Dave", "age" => "35"}
      child.update_properties_with_user_name "some_user", nil, new_properties
      child['age'].should == "35"
      child['name'].should == "Dave"
      child['last_known_location'].should == "London"
    end
    
    it "should not replace old properties when updated ones have nil value" do
      child = Child.new("origin" => "Croydon", "last_known_location" => "London")
      new_properties = {"origin" => nil, "last_known_location" => "Manchester"}
      child.update_properties_with_user_name "some_user", nil, new_properties
      child['last_known_location'].should == "Manchester"
      child['origin'].should == "Croydon"
    end

    it "should populate last_updated_by field with the user_name who is updating" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, {}
      child['last_updated_by'].should == 'jdoe'
    end

    it "should populate last_updated_at field with the time of the update" do
      current_time = Time.parse("Jan 17 2010 14:05")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, {}
      child['last_updated_at'].should == "17/01/2010 14:05"
    end 
    
    it "should update attachments when there is a photo update" do
      current_time = Time.parse("Jan 17 2010 14:05")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", uploadable_photo, {}
      child['_attachments']['photo-17-01-2010-1405']['data'].should_not be_blank
    end
    
    it "should not update attachments when the photo value is nil" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, {}
      child['_attachments'].should be_blank
      child['current_photo_key'].should be_nil
    end
  end

  describe "validating an existing child record" do
    it "should disallow file formats that are not photo formats" do
      photo = uploadable_photo
  
      child = Child.new
      child['last_known_location'] = "location"
      child.photo = photo
  
      child.save.should == true
  
      loaded_child = Child.get(child.id)
      loaded_child.save().should == true
  
      loaded_child.photo = uploadable_text_file
      loaded_child.save().should == false
    end
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
      current_time = Time.parse("14 Jan 2010 14:05")
      Time.stub!(:now).and_return current_time
      child = Child.new_with_user_name('some_user', 'some_field' => 'some_value')
      child['created_at'].should == "14/01/2010 14:05"
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
  
  describe "photo attachments" do    
    it "should create a field with current_photo_key on creation" do
      current_time = Time.parse("Jan 20 2010 17:10")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
    
      child['current_photo_key'].should == 'photo-20-01-2010-1710'
    end
    
    it "should have current_photo_key as photo attachment key on creation" do
      current_time = Time.parse("Jan 20 2010 17:10")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
    
      child['_attachments'].should have_key('photo-20-01-2010-1710')
    end
    
    it "should only have one attachment on creation" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      child['_attachments'].size.should == 1
    end
    
    it "should have data after creation" do
      current_time = Time.parse("Jan 20 2010 17:10")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      Child.get(child.id)['_attachments']['photo-20-01-2010-1710']['length'].should be > 0
    end
    
    it "should update current_photo_key on a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
    
      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff
    
      child['current_photo_key'].should == 'photo-20-02-2010-1204'
    end
    
    it "should have updated current_photo_key as photo attachment key on a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      
      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff
    
      child['_attachments'].should have_key('photo-20-02-2010-1204')
    end
    
    it "should be able to read photo after a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff
      
      Child.get(child.id)['_attachments']['photo-20-02-2010-1204']['length'].should be > 0
    end
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
    
    it "should 'from' field with original current_photo_key on a photo addition" do
      updated_at_time = Time.parse("Jan 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
    
      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff
      
      changes = child['histories'].first['changes']
      changes['current_photo_key']['from'].should == "photo-20-01-2010-1204"
    end

    it "should 'to' field with new current_photo_key on a photo addition" do
      updated_at_time = Time.parse("Jan 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
    
      updated_at_time = Time.parse("Feb 20 2010 12:04")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff
      
      changes = child['histories'].first['changes']
      changes['current_photo_key']['to'].should == "photo-20-02-2010-1204"
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
