require 'spec_helper'

describe Child, :type => :model do

  describe "update_properties_with_user_name" do

    it "should replace old properties with updated ones" do
      child = Child.new("name" => "Dave", "age" => "28", "last_known_location" => "London")
      new_properties = {"name" => "Dave", "age" => "35"}
      child.update_properties_with_user_name "some_user", nil, nil, nil, new_properties
      expect(child['age']).to eq("35")
      expect(child['name']).to eq("Dave")
      expect(child['last_known_location']).to eq("London")
    end

    it "should not replace old properties when updated ones have nil value" do
      child = Child.new("origin" => "Croydon", "last_known_location" => "London")
      new_properties = {"origin" => nil, "last_known_location" => "Manchester"}
      child.update_properties_with_user_name "some_user", nil, nil, nil, new_properties
      expect(child['last_known_location']).to eq("Manchester")
      expect(child['origin']).to eq("Croydon")
    end

    it "should not replace old properties when the existing records last_updated at is latest than the given last_updated_at" do
      child = Child.new("name" => "existing name", "last_updated_at" => "2013-01-01 00:00:01UTC")
      given_properties = {"name" => "given name", "last_updated_at" => "2012-12-12 00:00:00UTC"}
      child.update_properties_with_user_name "some_user", nil, nil, nil, given_properties
      expect(child["name"]).to eq("existing name")
      expect(child["last_updated_at"]).to eq("2013-01-01 00:00:01UTC")
    end

    it "should merge the histories of the given record with the current record if the last updated at of current record is greater than given record's" do
      existing_histories = JSON.parse "{\"user_name\":\"rapidftr\", \"datetime\":\"2013-01-01 00:00:01UTC\",\"changes\":{\"sex\":{\"to\":\"male\",\"from\":\"female\"}}}"
      given_histories = [existing_histories, JSON.parse("{\"user_name\":\"rapidftr\",\"datetime\":\"2012-01-01 00:00:02UTC\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]
      child = Child.new("name" => "existing name", "last_updated_at" => "2013-01-01 00:00:01UTC", "histories" => [existing_histories])
      given_properties = {"name" => "given name", "last_updated_at" => "2012-12-12 00:00:00UTC", "histories" => given_histories}
      child.update_properties_with_user_name "rapidftr", nil, nil, nil, given_properties
      histories = child["histories"]
      expect(histories.size).to eq(2)
      expect(histories.first["changes"]["sex"]["from"]).to eq("female")
      expect(histories.last["changes"]["name"]["to"]).to eq("new")
    end

    it "should delete the newly created media history(current_photo_key and recorded_audio) as the media names are changed before save of child record" do
      existing_histories = JSON.parse "{\"user_name\":\"rapidftr\", \"datetime\":\"2013-01-01 00:00:01UTC\",\"changes\":{\"sex\":{\"to\":\"male\",\"from\":\"female\"}}}"
      given_histories = [existing_histories,
                         JSON.parse("{\"datetime\":\"2013-02-04 06:55:03\",\"user_name\":\"rapidftr\",\"changes\":{\"current_photo_key\":{\"to\":\"2c097fa8-b9ab-4ae8-aa4d-1b7bda7dcb72\",\"from\":\"photo-364416240-2013-02-04T122424\"}},\"user_organisation\":\"N\\/A\"}"),
                         JSON.parse("{\"datetime\":\"2013-02-04 06:58:12\",\"user_name\":\"rapidftr\",\"changes\":{\"recorded_audio\":{\"to\":\"9252364d-c011-4af0-8739-0b1e9ed5c0ad1359961089870\",\"from\":\"\"}},\"user_organisation\":\"N\\/A\"}")
                        ]
      child = Child.new("name" => "existing name", "last_updated_at" => "2013-12-12 00:00:01UTC", "histories" => [existing_histories])
      given_properties = {"name" => "given name", "last_updated_at" => "2013-01-01 00:00:00UTC", "histories" => given_histories}
      child.update_properties_with_user_name "rapidftr", nil, nil, nil, given_properties
      histories = child["histories"]
      expect(histories.size).to eq(1)
      expect(histories.first["changes"]["current_photo_key"]).to be_nil
    end

    it "should assign the history of the given properties as it is if the current record has no history" do
      child = Child.new("name" => "existing name", "last_updated_at" => "2013-01-01 00:00:01UTC")
      given_properties = {"name" => "given name", "last_updated_at" => "2012-12-12 00:00:00UTC", "histories" => [JSON.parse("{\"user_name\":\"rapidftr\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]}
      child.update_properties_with_user_name "rapidftr", nil, nil, nil, given_properties
      histories = child["histories"]
      expect(histories.last["changes"]["name"]["to"]).to eq("new")
    end

    # This spec is almost always failing randomly, need to fix this spec if possible or think of other ways to test this?
    xit "should not add changes to history if its already added to the history" do
      FormSection.stub(:all_visible_child_fields =>
                            [Field.new(:type => Field::TEXT_FIELD, :name => "name", :display_name => "Name"),
                             Field.new(:type => Field::CHECK_BOXES, :name => "not_name")])
      child = Child.new("name" => "old", "last_updated_at" => "2012-12-12 00:00:00UTC")
      child.save!
      sleep 1
      changed_properties = {"name" => "new", "last_updated_at" => "2013-01-01 00:00:01UTC", "histories" => [JSON.parse("{\"user_name\":\"rapidftr\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]}
      child.update_properties_with_user_name "rapidftr", nil, nil, nil, changed_properties
      child.save!
      sleep 1
      child.update_properties_with_user_name "rapidftr", nil, nil, nil, changed_properties
      child.save!
      expect(child["histories"].size).to eq(1)
    end

    it "should populate last_updated_by field with the user_name who is updating" do
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      expect(child['last_updated_by']).to eq('jdoe')
    end

    it "should assign histories order by datetime of history" do
      child = Child.new
      first_history = double("history", :[] => "2010-01-01 01:01:02UTC")
      second_history = double("history", :[] => "2010-01-02 01:01:02UTC")
      third_history = double("history", :[] => "2010-01-02 01:01:03UTC")
      child["histories"] = [first_history, second_history, third_history]
      expect(child.ordered_histories).to eq([third_history, second_history, first_history])
    end

    it "should populate last_updated_at field with the time of the update" do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, "jan", 17, 19, 5, 0))
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      expect(child['last_updated_at']).to eq("2010-01-17 19:05:00UTC")
    end

    it "should not update attachments when the photo value is nil" do
      child = Child.new
      child.update_with_attachements({}, "mr jones")
      expect(child.photos).to be_empty
    end

    it "should update attachment when there is audio update" do
      allow(Clock).to receive(:now).and_return(Time.parse("Jan 17 2010 14:05:32"))
      child = Child.new
      child.update_properties_with_user_name "jdoe", nil, nil, uploadable_audio, {}
      expect(child['_attachments']['audio-2010-01-17T140532']['data']).not_to be_blank
    end

    it "should respond nil for photo when there is no photo associated with the child" do
      child = Child.new
      expect(child.photo).to eq(nil)
    end

    it "should update photo keys" do
      child = Child.new
      expect(child).to receive(:update_photo_keys)
      child.update_properties_with_user_name "jdoe", nil, nil, nil, {}
      expect(child.photos).to be_empty
    end

    it "should set flagged_at if the record has been flagged" do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, "jan", 17, 19, 5, 0))
      child = create_child("timothy cochran")
      child.update_properties_with_user_name 'some user name', nil, nil, nil, {:flag => true}
      expect(child.flag_at).to eq("2010-01-17 19:05:00UTC")
    end

    it "should set reunited_at if the record has been reunited" do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, "jan", 17, 19, 5, 0))
      child = create_child("timothy cochran")
      child.update_properties_with_user_name 'some user name', nil, nil, nil, {:reunited => true}
      expect(child.reunited_at).to eq("2010-01-17 19:05:00UTC")
    end

  end

  describe "validation" do
    before :each do
      create :form, :name => Child::FORM_NAME
    end
    context "child with only a photo registered" do
      before :each do
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
      end

      it 'should not be able to delete photo of child  with only one photo' do
        child = Child.new
        child.photo = uploadable_photo
        child.save
        child.delete_photos [child.primary_photo.name]
        expect(child).not_to be_valid
        expect(child.errors[:validate_has_at_least_one_field_value]).to eq(["Please fill in at least one field or upload a file"])
      end
    end

    it "should fail to validate if all fields are nil" do
      child = Child.new
      allow(FormSection).to receive(:all_visible_child_fields).and_return [Field.new(:type => 'numeric_field', :name => 'height', :display_name => "height")]
      expect(child).not_to be_valid
      expect(child.errors[:validate_has_at_least_one_field_value]).to eq(["Please fill in at least one field or upload a file"])
    end

    it "should fail to validate if all fields on child record are the default values" do
      child = Child.new({:height => "", :reunite_with_mother => ""})
      allow(FormSection).to receive(:all_visible_child_fields).and_return [
        Field.new(:type => Field::NUMERIC_FIELD, :name => 'height'),
        Field.new(:type => Field::RADIO_BUTTON, :name => 'reunite_with_mother'),
        Field.new(:type => Field::PHOTO_UPLOAD_BOX, :name => 'current_photo_key')]
      expect(child).not_to be_valid
      expect(child.errors[:validate_has_at_least_one_field_value]).to eq(["Please fill in at least one field or upload a file"])
    end

    it "should validate numeric types" do
      fields = [Field.new({:type => 'numeric_field', :name => 'height', :display_name => "height"})]
      child = Child.new
      child[:height] = "very tall"
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return(fields)

      expect(child).not_to be_valid
      expect(child.errors[:height]).to eq(["height must be a valid number"])
    end

    it "should validate multiple numeric types" do
      fields = [Field.new({:type => 'numeric_field', :name => 'height', :display_name => "height"}),
                Field.new({:type => 'numeric_field', :name => 'new_age', :display_name => "new age"})]
      child = Child.new
      child[:height] = "very tall"
      child[:new_age] = "very old"
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return(fields)

      expect(child).not_to be_valid
      expect(child.errors[:height]).to eq(["height must be a valid number"])
      expect(child.errors[:new_age]).to eq(["new age must be a valid number"])
    end

    it "should disallow text field values to be more than 200 chars" do
      FormSection.stub(:all_visible_child_fields_for_form =>
                        [Field.new(:type => Field::TEXT_FIELD, :name => "name", :display_name => "Name"),
                         Field.new(:type => Field::CHECK_BOXES, :name => "not_name")])
      child = Child.new :name => ('a' * 201)
      expect(child).not_to be_valid
      expect(child.errors[:name]).to eq(["Name cannot be more than 200 characters long"])
    end

    it "should disallow text area values to be more than 400,000 chars" do
      FormSection.stub(:all_visible_child_fields_for_form =>
                        [Field.new(:type => Field::TEXT_AREA, :name => "a_textfield", :display_name => "A textfield")])
      child = Child.new :a_textfield => ('a' * 400_001)
      expect(child).not_to be_valid
      expect(child.errors[:a_textfield]).to eq(["A textfield cannot be more than 400000 characters long"])
    end

    it "should allow text area values to be 400,000 chars" do
      FormSection.stub(:all_visible_child_fields_for_form =>
                        [Field.new(:type => Field::TEXT_AREA, :name => "a_textfield", :display_name => "A textfield")])
      child = Child.new :a_textfield => ('a' * 400_000)
      expect(child).to be_valid
    end

    it "should allow date fields formatted as dd M yy" do
      FormSection.stub(:all_visible_child_fields_for_form =>
                        [Field.new(:type => Field::DATE_FIELD, :name => "a_datefield", :display_name => "A datefield")])
      child = Child.new :a_datefield => ('27 Feb 2010')
      expect(child).to be_valid
    end

    it "should pass numeric fields that are valid numbers to 1 dp" do
      FormSection.stub(:all_visible_child_fields_for_form =>
                        [Field.new(:type => Field::NUMERIC_FIELD, :name => "height")])
      expect(Child.new(:height => "10.2")).to be_valid
    end

    it "should disallow file formats that are not photo formats" do
      child = Child.new
      child.photo = uploadable_photo_gif
      expect(child).not_to be_valid
      child.photo = uploadable_photo_bmp
      expect(child).not_to be_valid
    end

    it "should disallow file formats that are not supported audio formats" do
      child = Child.new
      child.audio = uploadable_photo_gif
      expect(child).not_to be_valid
      child.audio = uploadable_audio_amr
      expect(child).to be_valid
      child.audio = uploadable_audio_mp3
      expect(child).to be_valid
      child.audio = uploadable_audio_wav
      expect(child).not_to be_valid
      child.audio = uploadable_audio_ogg
      expect(child).not_to be_valid
    end

    it "should allow blank age" do
      child = Child.new({:age => "", :another_field => "blah"})
      expect(child).to be_valid
      child = Child.new :foo => "bar"
      expect(child).to be_valid
    end

    it "should disallow image file formats that are not png or jpg" do
      child = Child.new
      child.photo = uploadable_photo
      expect(child).to be_valid
      child.photo = uploadable_text_file
      expect(child).not_to be_valid
    end

    it "should disallow a photo larger than 10 megabytes" do
      photo = uploadable_large_photo
      child = Child.new
      child.photo = photo
      expect(child).not_to be_valid
    end

    it "should disllow an audio file larger than 10 megabytes" do
      child = Child.new
      child.audio = uploadable_large_audio
      expect(child).not_to be_valid
    end

    it "created_at should be a be a valid ISO date" do
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => 'I am not a date')
      expect(child).not_to be_valid
      child['created_at'] = '2010-01-14 14:05:00UTC'
      expect(child).to be_valid
    end

    it "last_updated_at should be a be a valid ISO date" do
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'last_updated_at' => 'I am not a date')
      expect(child).not_to be_valid
      child['last_updated_at'] = '2010-01-14 14:05:00UTC'
      expect(child).to be_valid
    end

    describe "validate_duplicate_of" do
      it "should validate duplicate_of field present when duplicate flag true" do
        child = Child.new('duplicate' => true, 'duplicate_of' => nil)
        expect(child).not_to be_valid
        expect(child.errors[:duplicate]).to include("A valid duplicate ID must be provided")
      end

      it "should not validate duplicate_of field present when duplicate flag is false" do
        child = Child.new('duplicate' => false, 'duplicate_of' => nil)
        child.valid?
        expect(child.errors[:duplicate]).not_to include("A valid duplicate ID must be provided")
      end
    end
  end

  describe 'save' do

    it "should not save file formats that are not photo formats" do
      child = Child.new
      child.photo = uploadable_photo_gif
      expect(child.save).to eq(false)
      child.photo = uploadable_photo_bmp
      expect(child.save).to eq(false)
    end

    it "should save file based on content type" do
      child = Child.new('created_by' => "me", 'created_organisation' => "stc")
      photo = uploadable_jpg_photo_without_file_extension
      child[:photo] = photo
      expect(child.save.present?).to eq(true)
    end

    it "should not save with file formats that are not supported audio formats" do
      child = Child.new('created_by' => "me", 'created_organisation' => "stc")
      child.audio = uploadable_photo_gif
      expect(child.save).to eq(false)
      child.audio = uploadable_audio_amr
      expect(child.save.present?).to eq(true)
      child.audio = uploadable_audio_mp3
      expect(child.save.present?).to eq(true)
      child.audio = uploadable_audio_wav
      expect(child.save).to eq(false)
      child.audio = uploadable_audio_ogg
      expect(child.save).to eq(false)
    end

    it "should save blank age" do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
      child = Child.new(:age => "", :another_field => "blah", 'created_by' => "me", 'created_organisation' => "stc")
      expect(child.save.present?).to eq(true)
      child = Child.new :foo => "bar"
      expect(child.save.present?).to eq(true)
    end

    it "should not save with image file formats that are not png or jpg" do
      photo = uploadable_photo
      child = Child.new('created_by' => "me", 'created_organisation' => "stc")
      child.photo = photo
      expect(child.save.present?).to eq(true)
      loaded_child = Child.get(child.id)
      expect(loaded_child.save.present?).to eq(true)
      loaded_child.photo = uploadable_text_file
      expect(loaded_child.save).to eq(false)
    end

    it "should not save with a photo larger than 10 megabytes" do
      photo = uploadable_large_photo
      child = Child.new('created_by' => "me", 'created_organisation' => "stc")
      child.photo = photo
      expect(child.valid?).to eq(false)
    end

    it "should not save with an audio file larger than 10 megabytes" do
      child = Child.new('created_by' => "me", 'created_organisation' => "stc")
      child.audio = uploadable_large_audio
      expect(child.save).to eq(false)
    end

  end

  describe "new_with_user_name" do

    it "should create regular child fields" do
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London', 'age' => '6')
      expect(child['last_known_location']).to eq('London')
      expect(child['age']).to eq('6')
    end

    it "should create a unique id" do
      allow(UUIDTools::UUID).to receive("random_create").and_return(12345)
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London')
      expect(child['unique_identifier']).to eq("12345")
    end

    it "should not create a unique id if already exists" do
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London', 'unique_identifier' => 'rapidftrxxx5bcde')
      expect(child['unique_identifier']).to eq("rapidftrxxx5bcde")
    end

    it "should create a created_by field with the user name" do
      child = create_child_with_created_by('jdoe', 'some_field' => 'some_value')
      expect(child['created_by']).to eq('jdoe')
    end

    it "should create a posted_at field with the current date" do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, "jan", 22, 14, 05, 0))
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value')
      expect(child['posted_at']).to eq("2010-01-22 14:05:00UTC")
    end

    describe "when the created at field is not supplied" do

      it "should create a created_at field with time of creation" do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, "jan", 14, 14, 5, 0))
        child = create_child_with_created_by('some_user', 'some_field' => 'some_value')
        expect(child['created_at']).to eq("2010-01-14 14:05:00UTC")
      end

    end

    describe "when the created at field is supplied" do

      it "should use the supplied created at value" do
        child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => '2010-01-14 14:05:00UTC')
        expect(child['created_at']).to eq("2010-01-14 14:05:00UTC")
      end
    end

  end

  describe ".form" do
    it "should return any form named Children" do
      form = create :form, :name => "Children"
      expect(Child.new.form).to eq(form)
    end
  end

  it "should automatically create a unique id" do
    allow(UUIDTools::UUID).to receive("random_create").and_return(12345)
    child = Child.new
    expect(child["unique_identifier"]).to eq("12345")
  end

  it "should return last 7 characters of unique id as short id" do
    allow(UUIDTools::UUID).to receive("random_create").and_return(1212127654321)
    child = Child.new
    expect(child.short_id).to eq("7654321")
  end

  describe "photo attachments" do

    before(:each) do
      allow(Clock).to receive(:now).and_return(Time.parse("Jan 20 2010 17:10:32"))
    end

    context "with no photos" do
      it "should have an empty set" do
        expect(Child.new.photos).to be_empty
      end

      it "should not have a primary photo" do
        expect(Child.new.primary_photo).to be_nil
      end
    end

    context "with a single new photo" do
      before :each do
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
        @child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
      end

      it "should only have one photo on creation" do
        expect(@child.photos.size).to eql 1
      end

      it "should be the primary photo" do
        expect(@child.primary_photo).to match_photo uploadable_photo
      end

    end

    context "with multiple new photos" do
      before :each do
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
        @child = Child.create('photo' => {'0' => uploadable_photo_jeff, '1' => uploadable_photo_jorge}, 'last_known_location' => 'London', 'created_by' => "me")
      end

      it "should have corrent number of photos after creation" do
        expect(@child.photos.size).to eql 2
      end

      it "should order by primary photo" do
        @child.primary_photo_id = @child["photo_keys"].last
        expect(@child.photos.first.name).to eq(@child.current_photo_key)
      end

      it "should return the first photo as a primary photo" do
        expect(@child.primary_photo).to match_photo uploadable_photo_jeff
      end

    end

    context "when rotating an existing photo" do
      before :each do
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
        @child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
        allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:32"))
      end

      it "should become the primary photo" do
        existing_photo = @child.primary_photo
        @child.rotate_photo(180)
        @child.save
        # TODO: should be a better way to check rotation other than stubbing Minimagic ?
        expect(@child.primary_photo).not_to match_photo existing_photo
      end

      it "should delete the original orientation" do
        existing_photo = @child.primary_photo
        @child.rotate_photo(180)
        @child.save
        expect(@child.primary_photo.name).to eql existing_photo.name
        expect(existing_photo).not_to match_photo @child.primary_photo
        expect(@child.photos.size).to eql 1
      end

    end

  end

  describe ".audio=" do

    before(:each) do
      @child = Child.new
      allow(@child).to receive(:attach)
      @file_attachment = mock_model(FileAttachment, :data => "My Data", :name => "some name", :mime_type => Mime::Type.lookup("audio/mpeg"))
    end

    it "should create an 'original' key in the audio hash" do
      @child.audio = uploadable_audio
      expect(@child['audio_attachments']).to have_key('original')
    end

    it "should create a FileAttachment with uploaded file and prefix 'audio'" do
      uploaded_file = uploadable_audio
      expect(FileAttachment).to receive(:from_uploadable_file).with(uploaded_file, "audio").and_return(@file_attachment)
      @child.audio = uploaded_file
    end

    it "should store the audio attachment key with the 'original' key in the audio hash" do
      allow(FileAttachment).to receive(:from_uploadable_file).and_return(@file_attachment)
      @child.audio = uploadable_audio
      expect(@child['audio_attachments']['original']).to eq('some name')
    end

    it "should store the audio attachment key with the 'mime-type' key in the audio hash" do
      allow(FileAttachment).to receive(:from_uploadable_file).and_return(@file_attachment)
      @child.audio = uploadable_audio
      expect(@child['audio_attachments']['mp3']).to eq('some name')
    end

  end

  describe ".add_audio_file" do

    before :each do
      @file = double("File")
      allow(File).to receive(:binread).with(@file).and_return("ABC")
      @file_attachment = FileAttachment.new("attachment_file_name", "audio/mpeg", "data")
    end

    it "should use Mime::Type.lookup to create file name postfix" do
      child = Child.new
      expect(Mime::Type).to receive(:lookup).exactly(2).times.with("audio/mpeg").and_return("abc".to_sym)
      child.add_audio_file(@file, "audio/mpeg")
    end

    it "should create a file attachment for the file with 'audio' prefix, mime mediatype as postfix" do
      child = Child.new
      allow(Mime::Type).to receive(:lookup).and_return("abc".to_sym)
      expect(FileAttachment).to receive(:from_file).with(@file, "audio/mpeg", "audio", "abc").and_return(@file_attachment)
      child.add_audio_file(@file, "audio/mpeg")
    end

    it "should add attachments key attachment to the audio hash using the content's media type as key" do
      child = Child.new
      allow(FileAttachment).to receive(:from_file).and_return(@file_attachment)
      child.add_audio_file(@file, "audio/mpeg")
      expect(child['audio_attachments']['mp3']).to eq("attachment_file_name")
    end

  end

  describe ".audio" do

    before :each do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
    end

    it "should return nil if no audio file has been set" do
      child = Child.new
      expect(child.audio).to be_nil
    end

    it "should check if 'original' audio attachment is present" do
      child = Child.create('audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")
      child['audio_attachments']['original'] = "ThisIsNotAnAttachmentName"
      expect(child).to receive(:has_attachment?).with('ThisIsNotAnAttachmentName').and_return(false)
      child.audio
    end

    it "should return nil if the recorded audio key is not an attachment" do
      child = Child.create('audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")
      child['audio_attachments']['original'] = "ThisIsNotAnAttachmentName"
      expect(child.audio).to be_nil
    end

    it "should retrieve attachment data for attachment key" do
      allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:32"))
      child = Child.create('audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")
      expect(child).to receive(:read_attachment).with('audio-2010-02-20T120432').and_return("Some audio")
      child.audio
    end

    it 'should create a FileAttachment with the read attachment and the attachments content type' do
      allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:32"))
      uploaded_amr = uploadable_audio_amr
      child = Child.create('audio' => uploaded_amr, 'created_by' => "me", 'created_organisation' => "stc")
      expected_data = 'LA! LA! LA! Audio Data'
      allow(child).to receive(:read_attachment).and_return(expected_data)
      expect(FileAttachment).to receive(:new).with('audio-2010-02-20T120432', uploaded_amr.content_type, expected_data)
      child.audio

    end

    it 'should return nil if child has not been saved' do
      child = Child.new('audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")
      expect(child.audio).to be_nil
    end

  end

  describe "audio attachment" do
    before :each do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => "stc"))
    end

    it "should create a field with recorded_audio on creation" do
      allow(Clock).to receive(:now).and_return(Time.parse("Jan 20 2010 17:10:32"))
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")

      expect(child['audio_attachments']['original']).to eq('audio-2010-01-20T171032')
    end

    it "should change audio file if a new audio file is set" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'audio' => uploadable_audio, 'created_by' => "me", 'created_organisation' => "stc")
      allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:32"))
      child.update_attributes :audio => uploadable_audio
      expect(child['audio_attachments']['original']).to eq('audio-2010-02-20T120432')
    end

  end

  describe "history log" do

    before do
      fields = [
        build(:text_field, :name => 'last_known_location'),
        build(:text_field, :name => 'age'),
        build(:text_field, :name => 'origin'),
        build(:radio_button_field, :name => 'gender', :option_strings => %w(male female)),
        build(:photo_field, :name => 'current_photo_key'),
        build(:audio_field, :name => 'recorded_audio')
      ]
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return(fields)
      mock_user = double({:organisation => 'UNICEF'})
      allow(User).to receive(:find_by_user_name).with(anything).and_return(mock_user)
    end

    it "should add a history entry when a record is created" do
      child = Child.create('last_known_location' => 'New York', 'created_by' => "me")
      expect(child['histories'].size).to be 1
      expect(child["histories"][0]).to eq({"changes" => {"child" => {:created => nil}}, "datetime" => nil, "user_name" => "me", "user_organisation" => "UNICEF"})
    end

    it "should update history with 'from' value on last_known_location update" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me")
      child['last_known_location'] = 'Philadelphia'
      child.save!
      changes = child['histories'].first['changes']
      expect(changes['last_known_location']['from']).to eq('New York')
    end

    it "should update history with 'to' value on last_known_location update" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me")
      child['last_known_location'] = 'Philadelphia'
      child.save!
      changes = child['histories'].first['changes']
      expect(changes['last_known_location']['to']).to eq('Philadelphia')
    end

    it "should update history with 'from' value on age update" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me")
      child['age'] = '6'
      child.save!
      changes = child['histories'].first['changes']
      expect(changes['age']['from']).to eq('8')
    end

    it "should update history with 'to' value on age update" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me")
      child['age'] = '6'
      child.save!
      changes = child['histories'].first['changes']
      expect(changes['age']['to']).to eq('6')
    end

    it "should update history with a combined history record when multiple fields are updated" do
      child = Child.create('age' => '8', 'last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me")
      child['age'] = '6'
      child['last_known_location'] = 'Philadelphia'
      child.save!
      expect(child['histories'].size).to eq(2)
      changes = child['histories'].first['changes']
      expect(changes['age']['from']).to eq('8')
      expect(changes['age']['to']).to eq('6')
      expect(changes['last_known_location']['from']).to eq('New York')
      expect(changes['last_known_location']['to']).to eq('Philadelphia')
    end

    it "should not record anything in the history if a save occured with no changes" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'New York', 'created_by' => "me", 'created_organisation' => "stc")
      loaded_child = Child.get(child.id)
      loaded_child.save!
      expect(child['histories'].size).to be 1
    end

    it "should not record empty string in the history if only change was spaces" do
      child = Child.create('origin' => '', 'photo' => uploadable_photo, 'last_known_location' => 'New York', 'created_by' => "me", 'created_organisation' => "stc")
      child['origin'] = '    '
      child.save!
      expect(child['histories'].size).to be 1
    end

    it "should not record history on populated field if only change was spaces" do
      child = Child.create('last_known_location' => 'New York', 'photo' => uploadable_photo, 'created_by' => "me", 'created_organisation' => "stc")
      child['last_known_location'] = ' New York   '
      child.save!
      expect(child['histories'].size).to be 1
    end

    it "should record history for newly populated field that previously was null" do
      # gender is the only field right now that is allowed to be nil when creating child document
      child = Child.create('gender' => nil, 'last_known_location' => 'London', 'photo' => uploadable_photo, 'created_by' => "me", 'created_organisation' => "stc")
      child['gender'] = 'Male'
      child.save!
      expect(child['histories'].first['changes']['gender']['from']).to be_nil
      expect(child['histories'].first['changes']['gender']['to']).to eq('Male')
    end

    it "should apend latest history to the front of histories" do
      child = Child.create('last_known_location' => 'London', 'photo' => uploadable_photo, 'created_by' => "me", 'created_organisation' => "stc")
      child['last_known_location'] = 'New York'
      child.save!
      child['last_known_location'] = 'Philadelphia'
      child.save!
      expect(child['histories'].size).to eq(3)
      expect(child['histories'][0]['changes']['last_known_location']['to']).to eq('Philadelphia')
      expect(child['histories'][1]['changes']['last_known_location']['to']).to eq('New York')
    end

    it "should update history with username from last_updated_by" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
      child['last_known_location'] = 'Philadelphia'
      child['last_updated_by'] = 'some_user'
      child.save!
      expect(child['histories'].first['user_name']).to eq('some_user')
      expect(child['histories'].first['user_organisation']).to eq('UNICEF')
    end

    it "should update history with the datetime from last_updated_at" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
      child['last_known_location'] = 'Philadelphia'
      child['last_updated_at'] = '2010-01-14 14:05:00UTC'
      child.save!
      expect(child['histories'].first['datetime']).to eq('2010-01-14 14:05:00UTC')
    end

    describe "photo logging" do

      before :each do
        allow(Clock).to receive(:now).and_return(Time.parse("Jan 20 2010 12:04:24"))
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
        @child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
        allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:24"))
      end

      it "should log new photo key on adding a photo" do
        @child.photo = uploadable_photo_jeff
        @child.save
        changes = @child['histories'].first['changes']
        # TODO: this should be instead child.photo_history.first.to or something like that
        expect(changes['photo_keys']['added'].first).to match(/photo.*?-2010-02-20T120424/)
      end

      it "should log multiple photos being added" do
        @child.photos = [uploadable_photo_jeff, uploadable_photo_jorge]
        @child.save
        changes = @child['histories'].first['changes']
        expect(changes['photo_keys']['added'].size).to eq(2)
        expect(changes['photo_keys']['deleted']).to be_nil
      end

      it "should log a photo being deleted" do
        @child.photos = [uploadable_photo_jeff, uploadable_photo_jorge]
        @child.save
        @child.delete_photos([@child.photos.first.name])
        @child.save
        changes = @child['histories'][1]['changes']
        expect(changes['photo_keys']['deleted'].size).to eq(1)
        expect(changes['photo_keys']['added']).to be_nil
      end

      it "should select a new primary photo if the current one is deleted" do
        @child.photos = [uploadable_photo_jeff]
        @child.save
        original_primary_photo_key = @child.photos[0].name
        jeff_photo_key = @child.photos[1].name
        expect(@child.primary_photo.name).to eq(original_primary_photo_key)
        @child.delete_photos([original_primary_photo_key])
        @child.save
        expect(@child.primary_photo.name).to eq(jeff_photo_key)
      end

      it "should take the current photo key during child creation and update it appropriately with the correct format" do
        @child = Child.create('photo' => {"0" => uploadable_photo, "1" => uploadable_photo_jeff}, 'last_known_location' => 'London', 'current_photo_key' => uploadable_photo_jeff.original_filename, 'created_by' => "me", 'created_organisation' => "stc")
        @child.save
        expect(@child.primary_photo.name).to eq(@child.photos.first.name)
        expect(@child.primary_photo.name).to start_with("photo-")
      end

      it "should not log anything if no photo changes have been made" do
        @child["last_known_location"] = "Moscow"
        @child.save
        changes = @child['histories'].first['changes']
        expect(changes['photo_keys']).to be_nil
      end

    end

    it "should maintain history when child is flagged and message is added" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
      child['flag'] = 'true'
      child['flag_message'] = 'Duplicate record!'
      child.save!
      flag_history = child['histories'].first['changes']['flag']
      expect(flag_history['from']).to be_nil
      expect(flag_history['to']).to eq('true')
      flag_message_history = child['histories'].first['changes']['flag_message']
      expect(flag_message_history['from']).to be_nil
      expect(flag_message_history['to']).to eq('Duplicate record!')
    end

    it "should maintain history when child is reunited and message is added" do
      child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
      child['reunited'] = 'true'
      child['reunited_message'] = 'Finally home!'
      child.save!
      reunited_history = child['histories'].first['changes']['reunited']
      expect(reunited_history['from']).to be_nil
      expect(reunited_history['to']).to eq('true')
      reunited_message_history = child['histories'].first['changes']['reunited_message']
      expect(reunited_message_history['from']).to be_nil
      expect(reunited_message_history['to']).to eq('Finally home!')
    end

    describe "photo changes" do

      before :each do
        allow(Clock).to receive(:now).and_return(Time.parse("Jan 20 2010 12:04:24"))
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
        @child = Child.create('photo' => uploadable_photo, 'last_known_location' => 'London', 'created_by' => "me", 'created_organisation' => "stc")
        allow(Clock).to receive(:now).and_return(Time.parse("Feb 20 2010 12:04:24"))
      end

      it "should log new photo key on adding a photo" do
        @child.photo = uploadable_photo_jeff
        @child.save
        changes = @child['histories'].first['changes']
        # TODO: this should be instead child.photo_history.first.to or something like that
        expect(changes['photo_keys']['added'].first).to match(/photo.*?-2010-02-20T120424/)
      end

      it "should log multiple photos being added" do
        @child.photos = [uploadable_photo_jeff, uploadable_photo_jorge]
        @child.save
        changes = @child['histories'].first['changes']
        expect(changes['photo_keys']['added'].size).to eq(2)
        expect(changes['photo_keys']['deleted']).to be_nil
      end

      it "should log a photo being deleted" do
        @child.photos = [uploadable_photo_jeff, uploadable_photo_jorge]
        @child.save
        @child.delete_photos([@child.photos.first.name])
        @child.save
        changes = @child['histories'][1]['changes']
        expect(changes['photo_keys']['deleted'].size).to eq(1)
        expect(changes['photo_keys']['added']).to be_nil
      end

      it "should select a new primary photo if the current one is deleted" do
        @child.photos = [uploadable_photo_jeff]
        @child.save
        original_primary_photo_key = @child.photos[0].name
        jeff_photo_key = @child.photos[1].name
        expect(@child.primary_photo.name).to eq(original_primary_photo_key)
        @child.delete_photos([original_primary_photo_key])
        @child.save
        expect(@child.primary_photo.name).to eq(jeff_photo_key)
      end

      it "should not log anything if no photo changes have been made" do
        @child["last_known_location"] = "Moscow"
        @child.save
        changes = @child['histories'].first['changes']
        expect(changes['photo_keys']).to be_nil
      end

      it "should delete items like _328 and _160x160 in attachments" do
        child = Child.new
        child.photo = uploadable_photo
        child.save

        photo_key = child.photos[0].name
        uploadable_photo_328 = FileAttachment.new(photo_key + "_328", "image/jpg", "data")
        uploadable_photo_160x160 = FileAttachment.new(photo_key + "_160x160", "image/jpg", "data")
        child.attach(uploadable_photo_328)
        child.attach(uploadable_photo_160x160)
        child.save
        expect(child[:_attachments].keys.size).to eq(3)

        child.delete_photos [child.primary_photo.name]
        child.save
        expect(child[:_attachments].keys.size).to eq(0)
      end
    end

  end

  describe ".has_one_interviewer?" do
    before :each do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
    end

    it "should be true if was created and not updated" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      expect(child.has_one_interviewer?).to be_truthy
    end

    it "should be true if was created and updated by the same person" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{"changes" => {"gender" => {"from" => nil, "to" => "Male"},
                                           "age" => {"from" => "1", "to" => "15"}},
                             "user_name" => "john",
                             "datetime" => "03/02/2011 21:48"},
                            {"changes" => {"last_known_location" => {"from" => "Rio", "to" => "Rio De Janeiro"}},
                             "datetime" => "03/02/2011 21:34",
                             "user_name" => "john"},
                            {"changes" => {"origin" => {"from" => "Rio", "to" => "Rio De Janeiro"}},
                             "user_name" => "john",
                             "datetime" => "03/02/2011 21:33"}]
      child['last_updated_by'] = 'john'
      expect(child.has_one_interviewer?).to be_truthy
    end

    it "should be false if created by one person and updated by another" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{"changes" => {"gender" => {"from" => nil, "to" => "Male"},
                                           "age" => {"from" => "1", "to" => "15"}},
                             "user_name" => "jane",
                             "datetime" => "03/02/2011 21:48"},
                            {"changes" => {"last_known_location" => {"from" => "Rio", "to" => "Rio De Janeiro"}},
                             "datetime" => "03/02/2011 21:34",
                             "user_name" => "john"},
                            {"changes" => {"origin" => {"from" => "Rio", "to" => "Rio De Janeiro"}},
                             "user_name" => "john",
                             "datetime" => "03/02/2011 21:33"}]
      child['last_updated_by'] = 'jane'
      expect(child.has_one_interviewer?).to be false
    end

    it "should be false if histories is empty" do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = []
      expect(child.has_one_interviewer?).to be_truthy
    end

  end

  describe ".photo" do

    it "should return nil if the record has no attached photo" do
      child = create_child "Bob McBobberson"
      expect(Child.all.find { |c| c.id == child.id }.photo).to be_nil
    end

  end

  describe ".audio" do

    it "should return nil if the record has no audio" do
      child = create_child "Bob McBobberson"
      expect(child.audio).to be_nil
    end

  end

  describe "primary_photo =" do

    before :each do
      @photo1 = uploadable_photo("features/resources/jorge.jpg")
      @photo2 = uploadable_photo("features/resources/jeff.png")
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'UNICEF'))
      @child = Child.new("name" => "Tom", 'created_by' => "me")
      @child.photo = {0 => @photo1, 1 => @photo2}
      @child.save
    end

    it "should update the primary photo selection" do
      photos = @child.photos
      orig_primary_photo = photos[0]
      new_primary_photo = photos[1]
      expect(@child.primary_photo_id).to eq(orig_primary_photo.name)
      @child.primary_photo_id = new_primary_photo.name
      @child.save
      expect(@child.primary_photo_id).to eq(new_primary_photo.name)
    end

    context "when selected photo id doesn't exist" do

      it "should show an error" do
        expect { @child.primary_photo_id = "non-existant-id" }.to raise_error "Failed trying to set 'non-existant-id' to primary photo: no such photo key"
      end

    end

  end

  context "duplicate" do
    before do
      Child.all.each { |child| child.destroy }
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'UNICEF'))
    end

    describe "mark_as_duplicate" do
      it "should set the duplicate field" do
        child_duplicate = Child.create('name' => "Jaco", 'unique_identifier' => 'jacoxxabcde', 'short_id' => "abcde12", 'created_by' => "me", 'created_organisation' => "stc")
        child_active = Child.create('name' => 'Jacobus', 'unique_identifier' => 'jacobusxxxunique', 'short_id' => 'nique12', 'created_by' => "me", 'created_organisation' => "stc")
        child_duplicate.mark_as_duplicate child_active['short_id']
        expect(child_duplicate.duplicate?).to be_truthy
        expect(child_duplicate.duplicate_of).to eq(child_active.id)
      end

      it "should set not set the duplicate field if child " do
        child_duplicate = Child.create('name' => "Jaco", 'unique_identifier' => 'jacoxxxunique')
        child_duplicate.mark_as_duplicate "I am not a valid id"
        expect(child_duplicate.duplicate_of).to be_nil
      end

      it "should set the duplicate field" do
        child_duplicate = Child.create('name' => "Jaco", 'unique_identifier' => 'jacoxxabcde', 'short_id' => "abcde12", 'created_by' => "me", 'created_organisation' => "stc")
        child_active = Child.create('name' => 'Jacobus', 'unique_identifier' => 'jacobusxxxunique', 'short_id' => 'nique12', 'created_by' => "me", 'created_organisation' => "stc")
        child_duplicate.mark_as_duplicate child_active['short_id']
        expect(child_duplicate.duplicate?).to be_truthy
        expect(child_duplicate.duplicate_of).to eq(child_active.id)
      end
    end

    it "should return all duplicate records" do
      record_active = Child.create(:name => "not a dupe", :unique_identifier => "someids", 'short_id' => 'someids', 'created_by' => "me", 'created_organisation' => "stc")
      record_duplicate = create_duplicate(record_active)

      duplicates = Child.by_duplicate_of(:key => record_active.id)
      all = Child.all

      expect(duplicates.count).to eq(1)
      expect(all.count).to eq(2)
      expect(duplicates.first.id).to eq(record_duplicate.id)
    end

    it "should return duplicate from a record" do
      record_active = Child.create(:name => "not a dupe", :unique_identifier => "someids", 'short_id' => 'someids', 'created_by' => "me", 'created_organisation' => "stc")
      record_duplicate = create_duplicate(record_active)

      duplicates = Child.by_duplicate_of(:key => record_active.id)
      expect(duplicates.count).to eq(1)
      expect(duplicates.first.id).to eq(record_duplicate.id)
    end

  end

  describe 'organisation' do
    it 'should get created user' do
      child = Child.new
      child['created_by'] = 'test'

      expect(User).to receive(:find_by_user_name).with('test').and_return('test1')
      expect(child.created_by_user).to eq('test1')
    end

    it 'should be set from user' do
      allow(User).to receive(:find_by_user_name).with('mj').and_return(double(:organisation => 'UNICEF'))
      child = Child.create 'name' => 'Jaco', :created_by => "mj"

      expect(child.created_organisation).to eq('UNICEF')
    end
  end

  describe "views" do
    describe "by id" do
      it "should return children by unique identifier" do
        child = create :child, :unique_identifier => "abcd"
        expect(Child.find_by_unique_identifier("abcd")).to eq(child)
      end

      it "should return children by short id" do
        child = create :child, :unique_identifier => "abcd1234567"
        expect(Child.find_by_short_id("1234567")).to eq(child)
      end
    end

    describe "user action log" do
      it "should return all children updated by a user" do
        child = Child.create!("created_by" => "some_other_user", "last_updated_by" => "a_third_user", "name" => "abc", "histories" => [{"user_name" => "brucewayne", "changes" => {"sex" => {"to" => "male", "from" => "female"}}}])

        expect(Child.all_connected_with("brucewayne")).to eq([Child.get(child.id)])
      end

      it "should not return children updated by other users" do
        Child.create!("created_by" => "some_other_user", "name" => "def", "histories" => [{"user_name" => "clarkkent", "changes" => {"sex" => {"to" => "male", "from" => "female"}}}])

        expect(Child.all_connected_with("peterparker")).to be_empty
      end

      it "should return the child once when modified twice by the same user" do
        child = Child.create!("created_by" => "some_other_user", "name" => "ghi", "histories" => [{"user_name" => "peterparker", "changes" => {"sex" => {"to" => "male", "from" => "female"}}}, {"user_name" => "peterparker", "changes" => {"sex" => {"to" => "female", "from" => "male"}}}])

        expect(Child.all_connected_with("peterparker")).to eq([Child.get(child.id)])
      end

      it "should return the child created by a user" do
        child = Child.create!("created_by" => "a_user", "name" => "def", "histories" => [{"user_name" => "clarkkent", "changes" => {"sex" => {"to" => "male", "from" => "female"}}}])

        expect(Child.all_connected_with("a_user")).to eq([Child.get(child.id)])
      end

      it "should not return duplicate records when same user had created and updated same child multiple times" do
        child = Child.create!("created_by" => "tonystark", "name" => "ghi", "histories" => [{"user_name" => "tonystark", "changes" => {"sex" => {"to" => "male", "from" => "female"}}}, {"user_name" => "tonystark", "changes" => {"sex" => {"to" => "female", "from" => "male"}}}])

        expect(Child.all_connected_with("tonystark")).to eq([Child.get(child.id)])
      end
    end

    describe "all ids and revs" do
      before do
        Child.all.each { |child| child.destroy }
      end

      it "should return all _ids and revs in the system" do
        child1 = create_child_with_created_by("user1", :name => "child1")
        child2 = create_child_with_created_by("user2", :name => "child2")
        child3 = create_child_with_created_by("user3", :name => "child3")
        child1.create!
        child2.create!
        child3.create!

        ids_and_revs = Child.fetch_all_ids_and_revs
        expect(ids_and_revs.count).to eq(3)
        expect(ids_and_revs).to match_array([{"_id" => child1.id, "_rev" => child1.rev}, {"_id" => child2.id, "_rev" => child2.rev}, {"_id" => child3.id, "_rev" => child3.rev}])
      end
    end
  end

  describe 'reindex' do
    it 'should reindex every 24 hours' do
      scheduler = double
      expect(scheduler).to receive(:every).with('24h').and_yield
      expect(Child).to receive(:reindex!).once.and_return(nil)
      Child.schedule scheduler
    end
  end

  describe '.update_solr_indices' do
    it 'should update Solr setup' do
      expect(Sunspot).to receive :setup
      Child.update_solr_indices
    end

    it 'should use all searchable fields' do
      expect(FormSection).to receive :all_sortable_field_names
      Child.update_solr_indices
    end
  end

  private

  def create_child(name, options = {})
    options.merge!("name" => name, "last_known_location" => "new york", 'created_by' => "me", 'created_organisation' => "stc")
    Child.create(options)
  end

  def create_duplicate(parent)
    duplicate = Child.create(:name => "dupe")
    duplicate.mark_as_duplicate(parent['short_id'])
    duplicate.save!
    duplicate
  end

  def create_child_with_created_by(created_by, options = {})
    user = User.new({:user_name => created_by, :organisation => "UNICEF"})
    Child.new_with_user_name user, options
  end
end
