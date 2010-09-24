require 'spec_helper'


describe Child do

  before do
    form_section = FormSection.new :unique_id => "basic_details"
    form_section.add_text_field("last_known_location")
    form_section.add_text_field("age")
    form_section.add_text_field("origin")
    form_section.add_field(Field.new_radio_button("gender", ["male", "female"]))
    form_section.add_field(Field.new_photo_upload_box("current_photo_key"))
    form_section.add_field(Field.new_audio_upload_box("recorded_audio"))

    FormSection.stub!(:all).and_return([form_section])
  end

  describe ".search" do
    before :each do
      Sunspot.remove_all(Child)
    end
    
    it "should return empty array for no match" do
      Child.search("Nothing").should == []
    end

    it "should return an exact match" do
      create_child("Exact")
      
      Child.search("Exact").map(&:name).should == ["Exact"]
    end
  
    it "should return a match that starts with the query" do
      create_child("Starts With")
      
      Child.search("Star").map(&:name).should == ["Starts With"]
    end
    
    it "should return a fuzzy match" do
      create_child("timithy")
      create_child("timothy")

      Child.search("timathy").map(&:name).should =~ ["timithy", "timothy"]
    end
    
    it "should search by exact match for unique id" do
      uuid = UUIDTools::UUID.random_create.to_s
      Child.create("name" => "kev", :unique_identifier => uuid, "last_known_location" => "new york",  'photo' => uploadable_photo)
      Child.create("name" => "kev", :unique_identifier => UUIDTools::UUID.random_create, "last_known_location" => "new york", 'photo' => uploadable_photo)
      results = Child.search(uuid)
      results.length.should == 1
      results.first[:unique_identifier].should == uuid
    end
    
    it "should match more than one word" do
      create_child("timothy cochran")      
      Child.search("timothy cochran").map(&:name).should =~ ["timothy cochran"]
    end
    
    it "should match more than one word with fuzzy search" do
      create_child("timothy cochran")      
      Child.search("timithy cichran").map(&:name).should =~ ["timothy cochran"]
    end
    
    it "should match more than one word with starts with" do
      create_child("timothy cochran")      
      Child.search("timo coch").map(&:name).should =~ ["timothy cochran"]
    end
    
    # it "should search across name and unique identifier" do
    #   Child.create("name" => "John Doe", "last_known_location" => "new york", "unique_identifier" => "ABC123")
    #   
    #   Child.search("ABC123").map(&:name).should == ["John Doe"]
    # end
  end

  describe "update_properties_with_user_name" do
    it "should reple old properties with updated ones" do
      child = Child.new("name" => "Dave", "age" => "28", "last_known_location" => "London")
      new_properties = {"name" => "Dave", "age" => "35"}
      child.update_properties_with_user_name "some_user", nil, nil, new_properties
      child['age'].should == "35"
      child['name'].should == "Dave"
      child['last_known_location'].should == "London"
    end

    it "should not replace old properties when updated ones have nil value" do
      child = Child.new("origin" => "Croydon", "last_known_location" => "London")
      new_properties = {"origin" => nil, "last_known_location" => "Manchester"}
      child.update_properties_with_user_name "some_user", nil, nil, new_properties
      child['last_known_location'].should == "Manchester"
      child['origin'].should == "Croydon"
    end

    it "should populate last_updated_by field with the user_name who is updating" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, {}
      child['last_updated_by'].should == 'jdoe'
    end

    it "should populate last_updated_at field with the time of the update" do
      current_time = Time.parse("Jan 17 2010 14:05")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, {}
      child['last_updated_at'].should == "17/01/2010 14:05"
    end

    it "should update attachments when there is a photo update" do
      current_time = Time.parse("Jan 17 2010 14:05:32")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", uploadable_photo, nil, {}
      child['_attachments']['photo-2010-01-17T140532']['data'].should_not be_blank
    end

    it "should not update attachments when the photo value is nil" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, {}
      child['_attachments'].should be_blank
      child['current_photo_key'].should be_nil
    end

    it "should update attachment when there is audio update" do
      current_time = Time.parse("Jan 17 2010 14:05:32")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, uploadable_audio, {}
      child['_attachments']['audio-2010-01-17T140532']['data'].should_not be_blank
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

    it "should not allow missing photo file" do
      child = Child.new
      child['last_known_location'] = 'some dummy location'
      child.should_not be_valid
      child.errors[:photo].should == ['Photo must be provided']
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
    pending "Seem to be having UTF-8 related problems - cv (talk to zk)"
    child = Child.new({'last_known_location'=> "\215\303\304n"})
    UUIDTools::UUID.stub("random_create").and_return('12345abcd')
    child.create_unique_id("george")
    child["unique_identifier"].should == "george\21512345"
  end

  describe "photo attachments" do
    it "should create a field with current_photo_key on creation" do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      child['current_photo_key'].should == 'photo-2010-01-20T171032'
    end

    it "should have current_photo_key as photo attachment key on creation" do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      child['_attachments'].should have_key('photo-2010-01-20T171032')
    end

    it "should only have one attachment on creation" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      child['_attachments'].size.should == 1
    end

    it "should have data after creation" do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      Child.get(child.id)['_attachments']['photo-2010-01-20T171032']['length'].should be > 0
    end

    it "should update current_photo_key on a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      child['current_photo_key'].should == 'photo-2010-02-20T120432'
    end

    it "should have updated current_photo_key as photo attachment key on a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      child['_attachments'].should have_key('photo-2010-02-20T120432')
    end

    it "should have photo data after a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      Child.get(child.id)['_attachments']['photo-2010-02-20T120432']['length'].should be > 0
    end

    it "should be able to read attachment after a photo change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')
      attachment = child.media_for_key(child['current_photo_key'])
      attachment.data.read.should == File.read(uploadable_photo.original_path)
    end
  end

  describe "audio attachment" do
    it "should create a field with recorded_audio on creation" do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio)

      child['recorded_audio'].should == 'audio-2010-01-20T171032'
    end

    it "should update recorded audio on a audio change" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio)

      updated_at_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :audio => uploadable_audio
      child['recorded_audio'].should == 'audio-2010-02-20T120432'
    end

  end

  describe "history log" do
    it "should not update history on initial creation of child document" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['histories'].should be_empty
    end

    it "should update history with 'from' value on last_known_location update" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['last_known_location'] = 'Philadelphia'
      child.save!

      changes = child['histories'].first['changes']
      changes['last_known_location']['from'].should == 'New York'
    end

    it "should update history with 'to' value on last_known_location update" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['last_known_location'] = 'Philadelphia'
      child.save!

      changes = child['histories'].first['changes']
      changes['last_known_location']['to'].should == 'Philadelphia'
    end

    it "should update history with 'from' value on age update" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['age'] = '6'
      child.save!

      changes = child['histories'].first['changes']
      changes['age']['from'].should == '8'
    end

    it "should update history with 'to' value on age update" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['age'] = '6'
      child.save!

      changes = child['histories'].first['changes']
      changes['age']['to'].should == '6'
    end

    it "should update history with a combined history record when multiple fields are updated" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo)

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
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'New York')

      loaded_child = Child.get(child.id)
      loaded_child.save!

      loaded_child['histories'].should be_empty
    end

    it "should not record empty string in the history if only change was spaces" do
      child = Child.create('origin' => '', 'photo' => uploadable_photo, 'last_known_location' => 'New York')

      child['origin'] = '    '
      child.save!

      child['histories'].should be_empty
    end

    it "should not record history on populated field if only change was spaces" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo)

      child['last_known_location'] = ' New York   '
      child.save!

      child['histories'].should be_empty
    end

    it "should record history for newly populated field that previously was null" do
      # gender is the only field right now that is allowed to be nil when creating child document
      child = Child.create('gender' => nil, 'last_known_location' => 'London', 'photo' => uploadable_photo)

      child['gender'] = 'Male'
      child.save!

      child['histories'].first['changes']['gender']['from'].should be_nil
      child['histories'].first['changes']['gender']['to'].should == 'Male'
    end

    it "should apend latest history to the front of histories" do
      child = Child.create('last_known_location' => 'London', 'photo' => uploadable_photo)

      child['last_known_location'] = 'New York'
      child.save!

      child['last_known_location'] = 'Philadelphia'
      child.save!

      child['histories'].size.should == 2
      child['histories'][0]['changes']['last_known_location']['to'].should == 'Philadelphia'
      child['histories'][1]['changes']['last_known_location']['to'].should == 'New York'
    end

    it "should 'from' field with original current_photo_key on a photo addition" do
      updated_at_time = Time.parse("Jan 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      changes = child['histories'].first['changes']
      changes['current_photo_key']['from'].should == "photo-2010-01-20T120424"
    end

    it "should 'to' field with new current_photo_key on a photo addition" do
      updated_at_time = Time.parse("Jan 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      changes = child['histories'].first['changes']
      changes['current_photo_key']['to'].should == "photo-2010-02-20T120424"
    end

    it "should update history with username from last_updated_by" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      child['last_known_location'] = 'Philadelphia'
      child['last_updated_by'] = 'some_user'
      child.save!

      child['histories'].first['user_name'].should == 'some_user'
    end

    it "should update history with the datetime from last_updated_at" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      child['last_known_location'] = 'Philadelphia'
      child['last_updated_at'] = 'some_time'
      child.save!

      child['histories'].first['datetime'].should == 'some_time'
    end
  end

  describe "when fetching children" do
    before do
      Child.all.each { |child| child.destroy }
    end

    it "should return list of children ordered by name" do
      UUIDTools::UUID.stub("random_create").and_return(12345)

      Child.create('photo' => uploadable_photo, 'name' => 'Zbu', 'last_known_location' => 'POA')
      Child.create('photo' => uploadable_photo, 'name' => 'Abu', 'last_known_location' => 'POA')

      childrens = Child.all
      childrens.first['name'].should == 'Abu'
    end

    it "should order children with blank names first" do
      UUIDTools::UUID.stub("random_create").and_return(12345)


      Child.create('photo' => uploadable_photo, 'name' => 'Zbu', 'last_known_location' => 'POA')
      Child.create('photo' => uploadable_photo, 'name' => 'Abu', 'last_known_location' => 'POA')
      Child.create('photo' => uploadable_photo, 'name' => '', 'last_known_location' => 'POA')

      childrens = Child.all
      childrens.first['name'].should == ''
      childrens.size.should == 3
    end
  end
  
  private
  
  def create_child(name)
    child = Child.create("name" => name, "last_known_location" => "new york", 'photo' => uploadable_photo)
    child.save!
  end 

end
