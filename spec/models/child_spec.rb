require 'spec_helper'


describe Child do

  describe 'build solar schema' do
      it "should build with advanced search fields" do
        Field.stub!(:all_text_names).and_return []
        Child.build_fields_for_solar.should == ["unique_identifier", "created_by"]
      end

      it "fields build with all fields in form sections" do
        form = FormSection.new(:name => "test_form")
        form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "name")
        form.save!

        Child.build_fields_for_solar.should include("name")

        FormSection.all.each{ |form| form.destroy }

      end

      it "should call Sunspot with all fields" do
        Sunspot.should_receive(:setup)
        Child.should_receive(:build_fields_for_solar)
        Child.build_solar_schema
      end

  end

  describe ".search" do
    before :each do
      Sunspot.remove_all(Child)
    end
    
    before :all do
      form = FormSection.new(:name => "test_form")
      form.fields << Field.new(:name => "name", :type => Field::TEXT_FIELD, :display_name => "name")
      form.save!
    end
    
    after :all do
      FormSection.all.each{ |form| form.destroy }
    end
    
    it "should return empty array if search is not valid" do
      search = mock("search", :query => "", :valid? => false)
      Child.search(search).should == []      
    end
    
    it "should return empty array for no match" do
      search = mock("search", :query => "Nothing", :valid? => true)
      Child.search(search).should == []
    end

    it "should return an exact match" do
      create_child("Exact")
      search = mock("search", :query => "Exact", :valid? => true)
      Child.search(search).map(&:name).should == ["Exact"]
    end
  
    it "should return a match that starts with the query" do
      create_child("Starts With")
      search = mock("search", :query => "Star", :valid? => true)      
      Child.search(search).map(&:name).should == ["Starts With"]
    end
    
    it "should return a fuzzy match" do
      create_child("timithy")
      create_child("timothy")
      search = mock("search", :query => "timothy", :valid? => true)      
      Child.search(search).map(&:name).should =~ ["timithy", "timothy"]
    end
    
    it "should search by exact match for unique id" do
      uuid = UUIDTools::UUID.random_create.to_s
      Child.create("name" => "kev", :unique_identifier => uuid, "last_known_location" => "new york")
      Child.create("name" => "kev", :unique_identifier => UUIDTools::UUID.random_create, "last_known_location" => "new york")
      search = mock("search", :query => uuid, :valid? => true)      
      results = Child.search(search)
      results.length.should == 1
      results.first[:unique_identifier].should == uuid
    end
    
    it "should match more than one word" do
      create_child("timothy cochran") 
      search = mock("search", :query => "timothy cochran", :valid? => true)           
      Child.search(search).map(&:name).should =~ ["timothy cochran"]
    end
    
    it "should match more than one word with fuzzy search" do
      create_child("timothy cochran")      
      search = mock("search", :query => "timithy cichran", :valid? => true)           
      Child.search(search).map(&:name).should =~ ["timothy cochran"]
    end
    
    it "should match more than one word with starts with" do
      create_child("timothy cochran")
      search = mock("search", :query => "timo coch", :valid? => true)                 
      Child.search(search).map(&:name).should =~ ["timothy cochran"]
    end
  end

  describe "update_properties_with_user_name" do
    it "should replace old properties with updated ones" do
      child = Child.new("name" => "Dave", "age" => "28", "last_known_location" => "London")
      new_properties = {"name" => "Dave", "age" => "35"}
      child.update_properties_with_user_name "some_user", nil, nil, nil, new_properties
      child['age'].should == "35"
      child['name'].should == "Dave"
      child['last_known_location'].should == "London"
    end

    it "should not replace old properties when updated ones have nil value" do
      child = Child.new("origin" => "Croydon", "last_known_location" => "London")
      new_properties = {"origin" => nil, "last_known_location" => "Manchester"}
      child.update_properties_with_user_name "some_user", nil, nil, nil, new_properties
      child['last_known_location'].should == "Manchester"
      child['origin'].should == "Croydon"
    end

    it "should populate last_updated_by field with the user_name who is updating" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      child['last_updated_by'].should == 'jdoe'
    end

    it "should populate last_updated_at field with the time of the update" do
      current_time_in_utc = Time.parse("17 Jan 2010 19:05UTC")
      current_time = mock()
      Time.stub!(:now).and_return current_time
      current_time.stub!(:getutc).and_return current_time_in_utc
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      child['last_updated_at'].should == "2010-01-17 19:05:00UTC"
    end

    it "should not update attachments when the photo value is nil" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      child.photos.should be_empty
    end

    it "should update attachment when there is audio update" do
      current_time = Time.parse("Jan 17 2010 14:05:32")
      Time.stub!(:now).and_return current_time
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, uploadable_audio, {}
      child['_attachments']['audio-2010-01-17T140532']['data'].should_not be_blank
    end

    it "should respond nil for photo when there is no photo associated with the child" do
      child = Child.new
      child.photo.should == nil
    end
    end
  
  describe "validation of custom fields" do
    it "should fail to validate if all fields are nil" do      
      child = Child.new
      FormSection.stub!(:all_enabled_child_fields).and_return [Field.new(:type => 'numeric_field', :name => 'height', :display_name => "height")]
      child.should_not be_valid
      child.errors[:validate_has_at_least_one_field_value].should == ["Please fill in at least one field or upload a file"]
    end
    it "should fail to validate if all fields on child record are the default values" do      
      child = Child.new({:height=>"",:reunite_with_mother=>""})
      FormSection.stub!(:all_enabled_child_fields).and_return [
                Field.new(:type => Field::NUMERIC_FIELD, :name => 'height'),
                Field.new(:type => Field::RADIO_BUTTON, :name => 'reunite_with_mother'),
                Field.new(:type => Field::PHOTO_UPLOAD_BOX, :name => 'current_photo_key') ]
      child.should_not be_valid
      child.errors[:validate_has_at_least_one_field_value].should == ["Please fill in at least one field or upload a file"]
    end
    
    it "should validate numeric types" do
      fields = [{:type => 'numeric_field', :name => 'height', :display_name => "height"}]
      child = Child.new
      child[:height] = "very tall"
      FormSection.stub!(:all_enabled_child_fields).and_return(fields)
      
      child.should_not be_valid
      child.errors.on(:height).should == ["height must be a valid number"]
    end
    
    it "should validate multiple numeric types" do
      fields = [
        {:type => 'numeric_field', :name => 'height', :display_name => "height"},
        {:type => 'numeric_field', :name => 'new_age', :display_name => "new age"}]
      child = Child.new
      child[:height] = "very tall"
      child[:new_age] = "very old"
      FormSection.stub!(:all_enabled_child_fields).and_return(fields)
      
      child.should_not be_valid
      child.errors.on(:height).should == ["height must be a valid number"]
      child.errors.on(:new_age).should == ["new age must be a valid number"]
    end
    it "should disallow text field values to be more than 200 chars" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::TEXT_FIELD, :name => "name", :display_name => "Name"), 
           Field.new(:type => Field::CHECK_BOXES, :name => "not_name")])
      child = Child.new :name => ('a' * 201)
      child.should_not be_valid
      child.errors[:name].should == ["Name cannot be more than 200 characters long"]
    end

    it "should disallow text area values to be more than 400,000 chars" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::TEXT_AREA, :name => "a_textfield", :display_name => "A textfield")])
      child = Child.new :a_textfield => ('a' * 400_001)
      child.should_not be_valid
      child.errors[:a_textfield].should == ["A textfield cannot be more than 400000 characters long"]
    end

    it "should allow text area values to be 400,000 chars" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::TEXT_AREA, :name => "a_textfield", :display_name => "A textfield")])
      child = Child.new :a_textfield => ('a' * 400_000)      
      child.should be_valid
    end

    it "should disallow date fields not formatted as dd M yy" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::DATE_FIELD, :name => "a_datefield", :display_name => "A datefield")])
      child = Child.new :a_datefield => ('2/27/2010')
      child.should_not be_valid
      child.errors[:a_datefield].should == ["A datefield must follow this format: 4 Feb 2010"]
    end

    it "should allow date fields formatted as dd M yy" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::DATE_FIELD, :name => "a_datefield", :display_name => "A datefield")])
      child = Child.new :a_datefield => ('27 Feb 2010')
      child.should be_valid
    end

    it "should pass numeric fields that are valid numbers to 1 dp" do
      FormSection.stub!(:all_enabled_child_fields =>
          [Field.new(:type => Field::NUMERIC_FIELD, :name => "height")])
      Child.new(:height => "10.2").should be_valid
    end
    
    it "should disallow file formats that are not photo formats" do
      child = Child.new

      child.photo = uploadable_photo_gif
      child.save.should == false

      child.photo = uploadable_photo_bmp
      child.save.should == false
    end
    
    it "should save file based on content type" do
      child = Child.new
      photo = uploadable_jpg_photo_without_file_extension
      child.photo = photo
      child.save.should == true
    end
    
    it "should disallow file formats that are not supported audio formats" do
      child = Child.new

      child.audio = uploadable_photo_gif
      child.save.should == false

      child.audio = uploadable_audio_amr
      child.save.should == true
      
      child.audio = uploadable_audio_mp3
      child.save.should == true
      
      child.audio = uploadable_audio_wav
      child.save.should == false
      
      child.audio = uploadable_audio_ogg
      child.save.should == false
      
    end
    
    it "should allow blank age" do
      child = Child.new({:age => "", :another_field=>"blah"})
      child.save.should == true
      
      child = Child.new :foo=>"bar"
      child.save.should == true
    end

    it "should disallow image file formats that are not png or jpg" do
      photo = uploadable_photo

      child = Child.new
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

		it "should create a posted_at field with the current date" do
			current_time_in_utc = Time.parse("22 Jan 2010 14:05UTC")
			Time.stub!(:now).and_return current_time_in_utc 
			child = Child.new_with_user_name('some_user', 'some_field' => 'some_value')
			child['posted_at'].should == "2010-01-22 14:05:00UTC"
		end

		describe "when the created at field is not supplied"do
			it "should create a created_at field with time of creation" do
				current_time_in_utc = Time.parse("14 Jan 2010 14:05UTC")
				current_time = mock()
				Time.stub!(:now).and_return current_time
				current_time.stub!(:getutc).and_return current_time_in_utc
				child = Child.new_with_user_name('some_user', 'some_field' => 'some_value')
				child['created_at'].should == "2010-01-14 14:05:00UTC"
			end
		end

		describe "when the created at field is supplied" do
			it "should use the supplied created at value" do
				child = Child.new_with_user_name('some_user', 'some_field' => 'some_value', 'created_at' => '2010-01-14 14:05:00UTC')
				child['created_at'].should == "2010-01-14 14:05:00UTC"
			end
			it "should be a be a valid ISO date" do
				child = Child.new_with_user_name('some_user', 'some_field' => 'some_value', 'created_at' => 'I am not a date')
				child.should_not be_valid
			end
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
    child = Child.new({'last_known_location'=> "\215\303\304n"})
    UUIDTools::UUID.stub("random_create").and_return('12345abcd')
    child.create_unique_id("george")
    child["unique_identifier"].should == "george\215\303\30412345"
  end

  describe "photo attachments" do
    before(:each) do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
    end
    
    context "with no photos" do
      it "should have an empty set" do
        Child.new.photos.should be_empty
      end
      
      it "should not have a primary photo" do
        Child.new.primary_photo.should be_nil
      end
    end

    context "with a single new photo" do
      let(:child) {Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')}    
      it "should only have one photo on creation" do
        child.photos.size.should eql 1
      end

      it "should be the primary photo" do
        child.primary_photo.should match_photo uploadable_photo
      end
    end

    context "with multiple new photos" do
      let(:child) {Child.create('photo' => {'0' => uploadable_photo_jeff, '1' => uploadable_photo_jorge}, 'last_known_location' => 'London')}    
      it "should have corrent number of photos after creation" do
        child.photos.size.should eql 2
      end
      
      it "should return the first photo as a primary photo" do
        child.primary_photo.should match_photo uploadable_photo_jeff
      end
    end
    
    context "when updating a photo" do
      let(:child) {Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')}  
      before(:each) do
        updated_at_time = Time.parse("Feb 20 2010 12:04:32")
        Time.stub!(:now).and_return updated_at_time
        child.update_attributes :photo => uploadable_photo_jeff
      end
      
      it "should become the primary photo" do
        child.primary_photo.should match_photo uploadable_photo_jeff
      end
    end
    
    context "when rotating an existing photo" do
      let(:child) {Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')}  
      before(:each) do
        updated_at_time = Time.parse("Feb 20 2010 12:04:32")
        Time.stub!(:now).and_return updated_at_time
      end
      
      it "should become the primary photo" do
        existing_photo = child.primary_photo
          child.rotate_photo(180)
        child.save

        #TODO: should be a better way to check rotation other than stubbing Minimagic ?
        child.primary_photo.should_not match_photo existing_photo
      end
      
      it "should delete the original orientation" do
        existing_photo = child.primary_photo
        child.rotate_photo(180)
        child.save

        child.primary_photo.name.should eql existing_photo.name
        existing_photo.should_not match_photo child.primary_photo  
        child.photos.size.should eql 1
      end
    end
  end

  describe ".audio=" do
    before(:each) do
      @child = Child.new
      @child.stub!(:attach)
      @file_attachment = mock_model(FileAttachment, :data => "My Data", :name => "some name", :mime_type => Mime::Type.lookup("audio/mpeg"))
    end

    it "should create an 'original' key in the audio hash" do
      @child.audio= uploadable_audio
      @child['audio_attachments'].should have_key('original')
    end

    it "should create a FileAttachment with uploaded file and prefix 'audio'" do
      uploaded_file = uploadable_audio
      FileAttachment.should_receive(:from_uploadable_file).with(uploaded_file, "audio").and_return(@file_attachment)
      @child.audio= uploaded_file
    end

    it "should store the audio attachment key with the 'original' key in the audio hash" do
      FileAttachment.stub!(:from_uploadable_file).and_return(@file_attachment)
      @child.audio= uploadable_audio
      @child['audio_attachments']['original'].should == 'some name'
    end

    it "should store the audio attachment key with the 'mime-type' key in the audio hash" do
      FileAttachment.stub!(:from_uploadable_file).and_return(@file_attachment)
      @child.audio= uploadable_audio
      @child['audio_attachments']['mp3'].should == 'some name'
    end

  end

  describe ".add_audio_file" do
    before (:each) do
      @file = stub!("File")
      @file.stub!(:read).and_return("ABC")
      @file_attachment = FileAttachment.new("attachment_file_name", "audio/mpeg", "data")
    end

    it "should use Mime::Type.lookup to create file name postfix" do
      child = Child.new()
      Mime::Type.should_receive(:lookup).exactly(2).times.with("audio/mpeg").and_return("abc".to_sym)
      child.add_audio_file(@file, "audio/mpeg")
    end

    it "should create a file attachment for the file with 'audio' prefix, mime mediatype as postfix" do
      child = Child.new()
      Mime::Type.stub!(:lookup).and_return("abc".to_sym)
      FileAttachment.should_receive(:from_file).with(@file, "audio/mpeg", "audio", "abc").and_return(@file_attachment)
      child.add_audio_file(@file, "audio/mpeg")
    end

    it "should add attachments key attachment to the audio hash using the content's media type as key" do
      child = Child.new()
      FileAttachment.stub!(:from_file).and_return(@file_attachment)
      child.add_audio_file(@file, "audio/mpeg")
      child['audio_attachments']['mp3'].should == "attachment_file_name"
    end

  end

  describe ".audio" do
    it "should return nil if no audio file has been set" do
      child = Child.new
      child.audio.should be_nil
    end

    it "should check if 'original' audio attachment is present" do
      child = Child.create('audio' => uploadable_audio)
      child['audio_attachments']['original'] = "ThisIsNotAnAttachmentName"

      child.should_receive(:has_attachment?).with('ThisIsNotAnAttachmentName').and_return(false)

      child.audio
    end

    it "should return nil if the recorded audio key is not an attachment" do
      child = Child.create('audio' => uploadable_audio)
      child['audio_attachments']['original'] = "ThisIsNotAnAttachmentName"
      child.audio.should be_nil
    end

    it "should retrieve attachment data for attachment key" do
      current_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('audio' => uploadable_audio)

      child.should_receive(:read_attachment).with('audio-2010-02-20T120432').and_return("Some audio")

      child.audio
    end

    it 'should create a FileAttachment with the read attachment and the attachments content type' do
      current_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return current_time
      uploaded_amr = uploadable_audio_amr
      child = Child.create('audio' => uploaded_amr)
      expected_data = 'LA! LA! LA! Audio Data'
      child.stub!(:read_attachment).and_return(expected_data)

      FileAttachment.should_receive(:new).with('audio-2010-02-20T120432', uploaded_amr.content_type, expected_data)

      child.audio

    end

  end


  describe "audio attachment" do

    it "should create a field with recorded_audio on creation" do
      current_time = Time.parse("Jan 20 2010 17:10:32")
      Time.stub!(:now).and_return current_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio)

      child['audio_attachments']['original'].should == 'audio-2010-01-20T171032'
    end

    it "should change audio file if a new audio file is set" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio)

      updated_at_time = Time.parse("Feb 20 2010 12:04:32")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :audio => uploadable_audio
      child['audio_attachments']['original'].should == 'audio-2010-02-20T120432'
    end

  end

  describe "history log" do    
    before do
			fields = [
					Field.new_text_field("last_known_location"),
					Field.new_text_field("age"),
					Field.new_text_field("origin"),
					Field.new_radio_button("gender", ["male", "female"]),
      		Field.new_photo_upload_box("current_photo_key"),
      		Field.new_audio_upload_box("recorded_audio")]
      FormSection.stub!(:all_enabled_child_fields).and_return(fields)
    end
    
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
      child = Child.create('photo' => uploadable_photo_jorge, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      changes = child['histories'].first['changes']
      
      #TODO: this should be instead child.photo_history.first.from or something like that
      changes['current_photo_key']['from'].should =~ /photo.*?-2010-01-20T120424/
    end

    it "should 'to' field with new current_photo_key on a photo addition" do
      updated_at_time = Time.parse("Jan 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London')

      updated_at_time = Time.parse("Feb 20 2010 12:04:24")
      Time.stub!(:now).and_return updated_at_time
      child.update_attributes :photo => uploadable_photo_jeff

      changes = child['histories'].first['changes']
      #TODO: this should be instead child.photo_history.first.to or something like that
      changes['current_photo_key']['to'].should =~ /photo.*?-2010-02-20T120424/
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
  
  describe ".has_one_interviewer?" do
    it "should be true if was created and not updated" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      
      child.has_one_interviewer?.should be_true
    end
    
    it "should be true if was created and updated by the same person" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{"changes"=>{"gender"=>{"from"=>nil, "to"=>"Male"}, 
                                          "age"=>{"from"=>"1", "to"=>"15"}}, 
                                          "user_name"=>"john", 
                                          "datetime"=>"03/02/2011 21:48"}, 
                             {"changes"=>{"last_known_location"=>{"from"=>"Rio", "to"=>"Rio De Janeiro"}}, 
                                         "datetime"=>"03/02/2011 21:34", 
                                         "user_name"=>"john"}, 
                             {"changes"=>{"origin"=>{"from"=>"Rio", "to"=>"Rio De Janeiro"}}, 
                                          "user_name"=>"john", 
                                          "datetime"=>"03/02/2011 21:33"}]
      child['last_updated_by'] = 'john'
      
      child.has_one_interviewer?.should be_true
    end
    
    it "should be false if created by one person and updated by another" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{"changes"=>{"gender"=>{"from"=>nil, "to"=>"Male"}, 
                                          "age"=>{"from"=>"1", "to"=>"15"}}, 
                                          "user_name"=>"jane", 
                                          "datetime"=>"03/02/2011 21:48"}, 
                             {"changes"=>{"last_known_location"=>{"from"=>"Rio", "to"=>"Rio De Janeiro"}}, 
                                         "datetime"=>"03/02/2011 21:34", 
                                         "user_name"=>"john"}, 
                             {"changes"=>{"origin"=>{"from"=>"Rio", "to"=>"Rio De Janeiro"}}, 
                                          "user_name"=>"john", 
                                          "datetime"=>"03/02/2011 21:33"}]
      child['last_updated_by'] = 'jane'
      
      child.has_one_interviewer?.should be_false
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

  describe ".photo" do
    it "should return nil if the record has no attached photo" do
      child = create_child "Bob McBobberson"
      Child.all.find{|c| c.id == child.id}.photo.should be_nil
    end
  end
  
  describe ".audio" do
    it "should return nil if the record has no audio" do
      child = create_child "Bob McBobberson"
      child.audio.should be_nil
    end
  end
 
  private
  
  def create_child(name)
    Child.create("name" => name, "last_known_location" => "new york")
  end

end
