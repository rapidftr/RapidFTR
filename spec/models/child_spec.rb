require 'spec_helper'

describe Child, :type => :model do

  describe 'update_properties_with_user_name' do

    it 'should replace old properties with updated ones' do
      child = Child.new('name' => 'Dave', 'age' => '28', 'last_known_location' => 'London')
      new_properties = {'name' => 'Dave', 'age' => '35'}
      child.update_properties_with_user_name 'some_user', nil, nil, nil, new_properties
      expect(child['age']).to eq('35')
      expect(child['name']).to eq('Dave')
      expect(child['last_known_location']).to eq('London')
    end

    it 'should not replace old properties when updated ones have nil value' do
      child = Child.new('origin' => 'Croydon', 'last_known_location' => 'London')
      new_properties = {'origin' => nil, 'last_known_location' => 'Manchester'}
      child.update_properties_with_user_name 'some_user', nil, nil, nil, new_properties
      expect(child['last_known_location']).to eq('Manchester')
      expect(child['origin']).to eq('Croydon')
    end

    it 'should not replace old properties when the existing records last_updated at is latest than the given last_updated_at' do
      child = Child.new('name' => 'existing name', 'last_updated_at' => '2013-01-01 00:00:01UTC')
      given_properties = {'name' => 'given name', 'last_updated_at' => '2012-12-12 00:00:00UTC'}
      child.update_properties_with_user_name 'some_user', nil, nil, nil, given_properties
      expect(child['name']).to eq('existing name')
      expect(child['last_updated_at']).to eq('2013-01-01 00:00:01UTC')
    end

    it "should merge the histories of the given record with the current record if the last updated at of current record is greater than given record's" do
      existing_histories = JSON.parse "{\"user_name\":\"rapidftr\", \"datetime\":\"2013-01-01 00:00:01UTC\",\"changes\":{\"sex\":{\"to\":\"male\",\"from\":\"female\"}}}"
      given_histories = [existing_histories, JSON.parse("{\"user_name\":\"rapidftr\",\"datetime\":\"2012-01-01 00:00:02UTC\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]
      child = Child.new('name' => 'existing name', 'last_updated_at' => '2013-01-01 00:00:01UTC', 'histories' => [existing_histories])
      given_properties = {'name' => 'given name', 'last_updated_at' => '2012-12-12 00:00:00UTC', 'histories' => given_histories}
      child.update_properties_with_user_name 'rapidftr', nil, nil, nil, given_properties
      histories = child['histories']
      expect(histories.size).to eq(2)
      expect(histories.first['changes']['sex']['from']).to eq('female')
      expect(histories.last['changes']['name']['to']).to eq('new')
    end

    it 'should delete the newly created media history(current_photo_key and recorded_audio) as the media names are changed before save of child record' do
      existing_histories = JSON.parse "{\"user_name\":\"rapidftr\", \"datetime\":\"2013-01-01 00:00:01UTC\",\"changes\":{\"sex\":{\"to\":\"male\",\"from\":\"female\"}}}"
      given_histories = [existing_histories,
                         JSON.parse("{\"datetime\":\"2013-02-04 06:55:03\",\"user_name\":\"rapidftr\",\"changes\":{\"current_photo_key\":{\"to\":\"2c097fa8-b9ab-4ae8-aa4d-1b7bda7dcb72\",\"from\":\"photo-364416240-2013-02-04T122424\"}},\"user_organisation\":\"N\\/A\"}"),
                         JSON.parse("{\"datetime\":\"2013-02-04 06:58:12\",\"user_name\":\"rapidftr\",\"changes\":{\"recorded_audio\":{\"to\":\"9252364d-c011-4af0-8739-0b1e9ed5c0ad1359961089870\",\"from\":\"\"}},\"user_organisation\":\"N\\/A\"}")
                        ]
      child = Child.new('name' => 'existing name', 'last_updated_at' => '2013-12-12 00:00:01UTC', 'histories' => [existing_histories])
      given_properties = {'name' => 'given name', 'last_updated_at' => '2013-01-01 00:00:00UTC', 'histories' => given_histories}
      child.update_properties_with_user_name 'rapidftr', nil, nil, nil, given_properties
      histories = child['histories']
      expect(histories.size).to eq(1)
      expect(histories.first['changes']['current_photo_key']).to be_nil
    end

    it 'should assign the history of the given properties as it is if the current record has no history' do
      child = Child.new('name' => 'existing name', 'last_updated_at' => '2013-01-01 00:00:01UTC')
      given_properties = {'name' => 'given name', 'last_updated_at' => '2012-12-12 00:00:00UTC', 'histories' => [JSON.parse("{\"user_name\":\"rapidftr\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]}
      child.update_properties_with_user_name 'rapidftr', nil, nil, nil, given_properties
      histories = child['histories']
      expect(histories.last['changes']['name']['to']).to eq('new')
    end

    # This spec is almost always failing randomly, need to fix this spec if possible or think of other ways to test this?
    xit 'should not add changes to history if its already added to the history' do
      FormSection.stub(:all_visible_child_fields =>
                       [Field.new(:type => Field::TEXT_FIELD, :name => 'name', :display_name => 'Name'),
                        Field.new(:type => Field::CHECK_BOXES, :name => 'not_name')])
      child = Child.new('name' => 'old', 'last_updated_at' => '2012-12-12 00:00:00UTC')
      child.save!
      sleep 1
      changed_properties = {'name' => 'new', 'last_updated_at' => '2013-01-01 00:00:01UTC', 'histories' => [JSON.parse("{\"user_name\":\"rapidftr\",\"changes\":{\"name\":{\"to\":\"new\",\"from\":\"old\"}}}")]}
      child.update_properties_with_user_name 'rapidftr', nil, nil, nil, changed_properties
      child.save!
      sleep 1
      child.update_properties_with_user_name 'rapidftr', nil, nil, nil, changed_properties
      child.save!
      expect(child['histories'].size).to eq(1)
    end

    it 'should populate last_updated_by field with the user_name who is updating' do
      child = Child.new
      child.update_properties_with_user_name 'jdoe', nil, nil, nil, {}
      expect(child['last_updated_by']).to eq('jdoe')
    end

    it 'should assign histories order by datetime of history' do
      child = Child.new
      first_history = double('history', :[] => '2010-01-01 01:01:02UTC')
      second_history = double('history', :[] => '2010-01-02 01:01:02UTC')
      third_history = double('history', :[] => '2010-01-02 01:01:03UTC')
      child['histories'] = [first_history, second_history, third_history]
      expect(child.ordered_histories).to eq([third_history, second_history, first_history])
    end

    it 'should populate last_updated_at field with the time of the update' do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 17, 19, 5, 0))
      child = Child.new
      child.update_properties_with_user_name 'jdoe', nil, nil, nil, {}
      expect(child['last_updated_at']).to eq('2010-01-17 19:05:00UTC')
    end

    it 'should not update attachments when the photo value is nil' do
      child = Child.new
      child.update_with_attachements({}, 'mr jones')
      expect(child.photos).to be_empty
    end

    it 'should update attachment when there is audio update' do
      allow(Clock).to receive(:now).and_return(Time.parse('Jan 17 2010 14:05:32'))
      child = Child.new
      child.update_properties_with_user_name 'jdoe', nil, nil, uploadable_audio, {}
      expect(child['_attachments']['audio-2010-01-17T140532']['data']).not_to be_blank
    end

    it 'should respond nil for photo when there is no photo associated with the child' do
      child = Child.new
      expect(child.photo).to eq(nil)
    end

    it 'should update photo keys' do
      child = Child.new
      expect(child).to receive(:update_photo_keys)
      child.update_properties_with_user_name 'jdoe', nil, nil, nil, {}
      expect(child.photos).to be_empty
    end

    it 'should set flagged_at if the record has been flagged' do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 17, 19, 5, 0))
      child = create(:child, :name => 'timothy cochran')
      child.update_properties_with_user_name 'some user name', nil, nil, nil, :flag => true
      expect(child.flag_at).to eq('2010-01-17 19:05:00UTC')
    end

    it 'should set reunited_at if the record has been reunited' do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 17, 19, 5, 0))
      child = create(:child, :name => 'timothy cochran')
      child.update_properties_with_user_name 'some user name', nil, nil, nil, :reunited => true
      expect(child.reunited_at).to eq('2010-01-17 19:05:00UTC')
    end

  end

  describe 'validation' do
    before :each do
      create :form, :name => Child::FORM_NAME
    end
    context 'child with only a photo registered' do
      before :each do
        allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
      end

      it 'should not be able to delete photo of child  with only one photo' do
        child = Child.new
        child.photo = uploadable_photo
        child.save
        child.delete_photos [child.primary_photo.name]
        expect(child).not_to be_valid
        expect(child.errors[:validate_has_at_least_one_field_value]).to eq(['Please fill in at least one field or upload a file'])
      end
    end

    it 'should fail to validate if all fields are nil' do
      child = Child.new
      allow(FormSection).to receive(:all_visible_child_fields).and_return [Field.new(:type => 'numeric_field', :name => 'height', :display_name => 'height')]
      expect(child).not_to be_valid
      expect(child.errors[:validate_has_at_least_one_field_value]).to eq(['Please fill in at least one field or upload a file'])
    end

    it 'should fail to validate if all fields on child record are the default values' do
      child = Child.new(:height => '', :reunite_with_mother => '')
      allow(FormSection).to receive(:all_visible_child_fields).and_return [
        Field.new(:type => Field::NUMERIC_FIELD, :name => 'height'),
        Field.new(:type => Field::RADIO_BUTTON, :name => 'reunite_with_mother'),
        Field.new(:type => Field::PHOTO_UPLOAD_BOX, :name => 'current_photo_key')]
      expect(child).not_to be_valid
      expect(child.errors[:validate_has_at_least_one_field_value]).to eq(['Please fill in at least one field or upload a file'])
    end

    it 'should validate numeric types' do
      fields = [Field.new(:type => 'numeric_field', :name => 'height', :display_name => 'height')]
      child = Child.new
      child[:height] = 'very tall'
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return(fields)

      expect(child).not_to be_valid
      expect(child.errors[:height]).to eq(['height must be a valid number'])
    end

    it 'should validate multiple numeric types' do
      fields = [Field.new(:type => 'numeric_field', :name => 'height', :display_name => 'height'),
                Field.new(:type => 'numeric_field', :name => 'new_age', :display_name => 'new age')]
      child = Child.new
      child[:height] = 'very tall'
      child[:new_age] = 'very old'
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return(fields)

      expect(child).not_to be_valid
      expect(child.errors[:height]).to eq(['height must be a valid number'])
      expect(child.errors[:new_age]).to eq(['new age must be a valid number'])
    end

    it 'should disallow text field values to be more than 200 chars' do
      FormSection.stub(:all_visible_child_fields_for_form =>
                       [Field.new(:type => Field::TEXT_FIELD, :name => 'name', :display_name => 'Name'),
                        Field.new(:type => Field::CHECK_BOXES, :name => 'not_name')])
      child = Child.new :name => ('a' * 201)
      expect(child).not_to be_valid
      expect(child.errors[:name]).to eq(['Name cannot be more than 200 characters long'])
    end

    it 'should disallow text area values to be more than 400,000 chars' do
      FormSection.stub(:all_visible_child_fields_for_form =>
                       [Field.new(:type => Field::TEXT_AREA, :name => 'a_textfield', :display_name => 'A textfield')])
      child = Child.new :a_textfield => ('a' * 400_001)
      expect(child).not_to be_valid
      expect(child.errors[:a_textfield]).to eq(['A textfield cannot be more than 400000 characters long'])
    end

    it 'should allow text area values to be 400,000 chars' do
      FormSection.stub(:all_visible_child_fields_for_form =>
                       [Field.new(:type => Field::TEXT_AREA, :name => 'a_textfield', :display_name => 'A textfield')])
      child = Child.new :a_textfield => ('a' * 400_000)
      expect(child).to be_valid
    end

    it 'should allow date fields formatted as dd M yy' do
      FormSection.stub(:all_visible_child_fields_for_form =>
                       [Field.new(:type => Field::DATE_FIELD, :name => 'a_datefield', :display_name => 'A datefield')])
      child = Child.new :a_datefield => ('27 Feb 2010')
      expect(child).to be_valid
    end

    it 'should pass numeric fields that are valid numbers to 1 dp' do
      FormSection.stub(:all_visible_child_fields_for_form =>
                       [Field.new(:type => Field::NUMERIC_FIELD, :name => 'height')])
      expect(Child.new(:height => '10.2')).to be_valid
    end

    it 'should allow blank age' do
      child = Child.new(:age => '', :another_field => 'blah')
      expect(child).to be_valid
      child = Child.new :foo => 'bar'
      expect(child).to be_valid
    end

    it 'created_at should be a be a valid ISO date' do
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => 'I am not a date')
      expect(child).not_to be_valid
      child['created_at'] = '2010-01-14 14:05:00UTC'
      expect(child).to be_valid
    end

    it 'last_updated_at should be a be a valid ISO date' do
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'last_updated_at' => 'I am not a date')
      expect(child).not_to be_valid
      child['last_updated_at'] = '2010-01-14 14:05:00UTC'
      expect(child).to be_valid
    end

    describe 'validate_duplicate_of' do
      it 'should validate duplicate_of field present when duplicate flag true' do
        child = Child.new('duplicate' => true, 'duplicate_of' => nil)
        expect(child).not_to be_valid
        expect(child.errors[:duplicate]).to include('A valid duplicate ID must be provided')
      end

      it 'should not validate duplicate_of field present when duplicate flag is false' do
        child = Child.new('duplicate' => false, 'duplicate_of' => nil)
        child.valid?
        expect(child.errors[:duplicate]).not_to include('A valid duplicate ID must be provided')
      end
    end
  end

  describe 'save' do

    it 'should save blank age' do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
      child = Child.new(:age => '', :another_field => 'blah', 'created_by' => 'me', 'created_organisation' => 'stc')
      expect(child.save.present?).to eq(true)
      child = Child.new :foo => 'bar'
      expect(child.save.present?).to eq(true)
    end

  end

  describe 'new_with_user_name' do

    it 'should create regular child fields' do
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London', 'age' => '6')
      expect(child['last_known_location']).to eq('London')
      expect(child['age']).to eq('6')
    end

    it 'should create child with photo' do
      child = create_child_with_created_by('john doe', 'photo' => uploadable_photo)
      child.save

      expect(child.photos.size).to eq 1
      expect(child.photo_keys.size).to eq 1
      expect(child.primary_photo).to match_photo uploadable_photo
    end

    it 'should create a unique id' do
      allow(UUIDTools::UUID).to receive('random_create').and_return(12_345)
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London')
      expect(child['unique_identifier']).to eq('12345')
    end

    it 'should not create a unique id if already exists' do
      child = create_child_with_created_by('jdoe', 'last_known_location' => 'London', 'unique_identifier' => 'rapidftrxxx5bcde')
      expect(child['unique_identifier']).to eq('rapidftrxxx5bcde')
    end

    it 'should create a created_by field with the user name' do
      child = create_child_with_created_by('jdoe', 'some_field' => 'some_value')
      expect(child['created_by']).to eq('jdoe')
    end

    it 'should create a posted_at field with the current date' do
      allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
      child = create_child_with_created_by('some_user', 'some_field' => 'some_value')
      expect(child['posted_at']).to eq('2010-01-22 14:05:00UTC')
    end

    describe 'when the created at field is not supplied' do

      it 'should create a created_at field with time of creation' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 14, 14, 5, 0))
        child = create_child_with_created_by('some_user', 'some_field' => 'some_value')
        expect(child['created_at']).to eq('2010-01-14 14:05:00UTC')
      end

    end

    describe 'when the created at field is supplied' do

      it 'should use the supplied created at value' do
        child = create_child_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => '2010-01-14 14:05:00UTC')
        expect(child['created_at']).to eq('2010-01-14 14:05:00UTC')
      end
    end

  end

  describe '.form' do
    it 'should return any form named Children' do
      form = create :form, :name => 'Children'
      expect(Child.new.form).to eq(form)
    end
  end

  it 'should automatically create a unique id' do
    allow(UUIDTools::UUID).to receive('random_create').and_return(12_345)
    child = Child.new
    expect(child['unique_identifier']).to eq('12345')
  end

  it 'should return last 7 characters of unique id as short id' do
    allow(UUIDTools::UUID).to receive('random_create').and_return(1_212_127_654_321)
    child = Child.new
    expect(child.short_id).to eq('7654321')
  end

  describe '.has_one_interviewer?' do
    before :each do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
    end

    it 'should be true if was created and not updated' do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      expect(child).to have_one_interviewer
    end

    it 'should be true if was created and updated by the same person' do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{'changes' => {'gender' => {'from' => nil, 'to' => 'Male'},
                                           'age' => {'from' => '1', 'to' => '15'}},
                             'user_name' => 'john',
                             'datetime' => '03/02/2011 21:48'},
                            {'changes' => {'last_known_location' => {'from' => 'Rio', 'to' => 'Rio De Janeiro'}},
                             'datetime' => '03/02/2011 21:34',
                             'user_name' => 'john'},
                            {'changes' => {'origin' => {'from' => 'Rio', 'to' => 'Rio De Janeiro'}},
                             'user_name' => 'john',
                             'datetime' => '03/02/2011 21:33'}]
      child['last_updated_by'] = 'john'
      expect(child).to have_one_interviewer
    end

    it 'should be false if created by one person and updated by another' do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = [{'changes' => {'gender' => {'from' => nil, 'to' => 'Male'},
                                           'age' => {'from' => '1', 'to' => '15'}},
                             'user_name' => 'jane',
                             'datetime' => '03/02/2011 21:48'},
                            {'changes' => {'last_known_location' => {'from' => 'Rio', 'to' => 'Rio De Janeiro'}},
                             'datetime' => '03/02/2011 21:34',
                             'user_name' => 'john'},
                            {'changes' => {'origin' => {'from' => 'Rio', 'to' => 'Rio De Janeiro'}},
                             'user_name' => 'john',
                             'datetime' => '03/02/2011 21:33'}]
      child['last_updated_by'] = 'jane'
      expect(child.has_one_interviewer?).to be false
    end

    it 'should be false if histories is empty' do
      child = Child.create('last_known_location' => 'London', 'created_by' => 'john')
      child['histories'] = []
      expect(child).to have_one_interviewer
    end

  end

  describe '.photo' do

    it 'should return nil if the record has no attached photo' do
      child = create_child 'Bob McBobberson'
      expect(Child.all.find { |c| c.id == child.id }.photo).to be_nil
    end

  end

  describe '.audio' do

    it 'should return nil if the record has no audio' do
      child = create_child 'Bob McBobberson'
      expect(child.audio).to be_nil
    end

  end

  describe 'primary_photo =' do

    before :each do
      @photo1 = uploadable_photo('features/resources/jorge.jpg')
      @photo2 = uploadable_photo('features/resources/jeff.png')
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'UNICEF'))
      @child = Child.new('name' => 'Tom', 'created_by' => 'me')
      @child.photo = {0 => @photo1, 1 => @photo2}
      @child.save
    end

    it 'should update the primary photo selection' do
      photos = @child.photos
      orig_primary_photo = photos[0]
      new_primary_photo = photos[1]
      expect(@child.primary_photo_id).to eq(orig_primary_photo.name)
      @child.primary_photo_id = new_primary_photo.name
      @child.save
      expect(@child.primary_photo_id).to eq(new_primary_photo.name)
    end

    context "when selected photo id doesn't exist" do

      it 'should show an error' do
        expect { @child.primary_photo_id = 'non-existant-id' }.to raise_error "Failed trying to set 'non-existant-id' to primary photo: no such photo key"
      end

    end

  end

  context 'duplicate' do
    before do
      Child.all.each { |child| child.destroy }
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'UNICEF'))
    end

    describe 'mark_as_duplicate' do
      it 'should set the duplicate field' do
        child_duplicate = Child.create('name' => 'Jaco', 'unique_identifier' => 'jacoxxabcde', 'short_id' => 'abcde12', 'created_by' => 'me', 'created_organisation' => 'stc')
        child_active = Child.create('name' => 'Jacobus', 'unique_identifier' => 'jacobusxxxunique', 'short_id' => 'nique12', 'created_by' => 'me', 'created_organisation' => 'stc')
        child_duplicate.mark_as_duplicate child_active['short_id']
        expect(child_duplicate).to be_duplicate
        expect(child_duplicate.duplicate_of).to eq(child_active.id)
      end

      it 'should set not set the duplicate field if child ' do
        child_duplicate = Child.create('name' => 'Jaco', 'unique_identifier' => 'jacoxxxunique')
        child_duplicate.mark_as_duplicate 'I am not a valid id'
        expect(child_duplicate.duplicate_of).to be_nil
      end

      it 'should set the duplicate field' do
        child_duplicate = Child.create('name' => 'Jaco', 'unique_identifier' => 'jacoxxabcde', 'short_id' => 'abcde12', 'created_by' => 'me', 'created_organisation' => 'stc')
        child_active = Child.create('name' => 'Jacobus', 'unique_identifier' => 'jacobusxxxunique', 'short_id' => 'nique12', 'created_by' => 'me', 'created_organisation' => 'stc')
        child_duplicate.mark_as_duplicate child_active['short_id']
        expect(child_duplicate).to be_duplicate
        expect(child_duplicate.duplicate_of).to eq(child_active.id)
      end
    end

    it 'should return all duplicate records' do
      record_active = Child.create(:name => 'not a dupe', :unique_identifier => 'someids', 'short_id' => 'someids', 'created_by' => 'me', 'created_organisation' => 'stc')
      record_duplicate = create_duplicate(record_active)

      duplicates = Child.by_duplicate_of(:key => record_active.id)
      all = Child.all

      expect(duplicates.count).to eq(1)
      expect(all.count).to eq(2)
      expect(duplicates.first.id).to eq(record_duplicate.id)
    end

    it 'should return duplicate from a record' do
      record_active = Child.create(:name => 'not a dupe', :unique_identifier => 'someids', 'short_id' => 'someids', 'created_by' => 'me', 'created_organisation' => 'stc')
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
      child = Child.create 'name' => 'Jaco', :created_by => 'mj'

      expect(child.created_organisation).to eq('UNICEF')
    end
  end

  describe 'views' do
    describe 'by id' do
      it 'should return children by unique identifier' do
        child = create :child, :unique_identifier => 'abcd'
        expect(Child.find_by_unique_identifier('abcd')).to eq(child)
      end

      it 'should return children by short id' do
        child = create :child, :unique_identifier => 'abcd1234567'
        expect(Child.find_by_short_id('1234567')).to eq(child)
      end
    end

    describe 'user action log' do
      it 'should return all children updated by a user' do
        child = Child.create!('created_by' => 'some_other_user', 'last_updated_by' => 'a_third_user', 'name' => 'abc', 'histories' => [{'user_name' => 'brucewayne', 'changes' => {'sex' => {'to' => 'male', 'from' => 'female'}}}])

        expect(Child.all_connected_with('brucewayne')).to eq([Child.get(child.id)])
      end

      it 'should not return children updated by other users' do
        Child.create!('created_by' => 'some_other_user', 'name' => 'def', 'histories' => [{'user_name' => 'clarkkent', 'changes' => {'sex' => {'to' => 'male', 'from' => 'female'}}}])

        expect(Child.all_connected_with('peterparker')).to be_empty
      end

      it 'should return the child once when modified twice by the same user' do
        child = Child.create!('created_by' => 'some_other_user', 'name' => 'ghi', 'histories' => [{'user_name' => 'peterparker', 'changes' => {'sex' => {'to' => 'male', 'from' => 'female'}}}, {'user_name' => 'peterparker', 'changes' => {'sex' => {'to' => 'female', 'from' => 'male'}}}])

        expect(Child.all_connected_with('peterparker')).to eq([Child.get(child.id)])
      end

      it 'should return the child created by a user' do
        child = Child.create!('created_by' => 'a_user', 'name' => 'def', 'histories' => [{'user_name' => 'clarkkent', 'changes' => {'sex' => {'to' => 'male', 'from' => 'female'}}}])

        expect(Child.all_connected_with('a_user')).to eq([Child.get(child.id)])
      end

      it 'should not return duplicate records when same user had created and updated same child multiple times' do
        child = Child.create!('created_by' => 'tonystark', 'name' => 'ghi', 'histories' => [{'user_name' => 'tonystark', 'changes' => {'sex' => {'to' => 'male', 'from' => 'female'}}}, {'user_name' => 'tonystark', 'changes' => {'sex' => {'to' => 'female', 'from' => 'male'}}}])

        expect(Child.all_connected_with('tonystark')).to eq([Child.get(child.id)])
      end
    end

    describe 'all ids and revs' do
      before do
        Child.all.each { |child| child.destroy }
      end

      it 'should return all _ids and revs in the system' do
        child1 = create_child_with_created_by('user1', :name => 'child1')
        child2 = create_child_with_created_by('user2', :name => 'child2')
        child3 = create_child_with_created_by('user3', :name => 'child3')
        child1.create!
        child2.create!
        child3.create!

        ids_and_revs = Child.fetch_all_ids_and_revs
        expect(ids_and_revs.count).to eq(3)
        expect(ids_and_revs).to match_array([{'_id' => child1.id, '_rev' => child1.rev}, {'_id' => child2.id, '_rev' => child2.rev}, {'_id' => child3.id, '_rev' => child3.rev}])
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

    it 'should use all searchable fields for the correct form section' do
      expect(FormSection).to receive(:all_form_sections_for).and_return([])
      Child.update_solr_indices
    end
  end

  describe 'searchable_field_names' do
    before :each do
      reset_couchdb!
    end

    it 'should include highlighted fields, short_id, and unique_identifier' do
      form = create :form, :name => Child::FORM_NAME
      create :form_section, :form => form, :name => 'Basic Identity', :fields => [build(:field, :name => 'first_name', :highlighted => true)]

      expect(Child.searchable_field_names).to eq ['first_name', :unique_identifier, :short_id]
    end
  end

  describe '#confirmed_matches' do
    before :each do
      reset_couchdb!
    end

    it 'should return a confirmed match' do
      child_x = create(:child, :id => 'child_id_x')
      PotentialMatch.create :enquiry_id => 'enquiry_id_x',
                            :child_id => 'child_id_x',
                            :confirmed => true
      expect(child_x.confirmed_matches).to_not be_nil
      expect(child_x.confirmed_matches[0].enquiry_id).to eq('enquiry_id_x')
    end

    it 'should return multiple confirmed matches' do
      child_x = create(:child, :id => 'child_id_x')
      enquiry_x = create(:enquiry, :id => 'enquiry_id_x')
      enquiry_y = create(:enquiry, :id => 'enquiry_id_y')
      PotentialMatch.create :enquiry_id => 'enquiry_id_y',
                            :child_id => 'child_id_x',
                            :confirmed => true
      PotentialMatch.create :enquiry_id => 'enquiry_id_x',
                            :child_id => 'child_id_x',
                            :confirmed => true
      expect(child_x.confirmed_matches).to_not be_nil
      expect(child_x.confirmed_matches.size).to be(2)
      expect(child_x.confirmed_matches.map(&:enquiry)).to include(enquiry_x, enquiry_y)
    end

    it 'should not return unconfirmed matches' do
      child_x = create(:child, :id => 'child_id_x')
      PotentialMatch.create :enquiry_id => 'enquiry_id_x',
                            :child_id => 'child_id_x',
                            :confirmed => false
      expect(Enquiry).to_not receive(:find)
      expect(child_x.confirmed_matches).to be_empty
    end
  end

  describe '#potential_matches', :solr => true do

    before :each do
      reset_couchdb!
      Sunspot.setup(Child) do
        text :location
        text :name
        text :gender
      end

      form = create :form, :name => Enquiry::FORM_NAME

      SystemVariable.create :name => 'SCORE_THRESHOLD', :value => '0'

      create :form_section, :name => 'test_form', :fields => [
        build(:text_field, :name => 'child_name'),
        build(:text_field, :name => 'location'),
        build(:text_field, :name => 'gender'),
        build(:text_field, :name => 'enquirer_name')
      ], :form => form
    end

    it 'return potential matches' do
      child = create :child, :name => 'Eduardo'
      enquiry1 = create :enquiry, :child_name => 'Eduardo', :enquirer_name => 'Aunt'
      enquiry2 = create :enquiry, :child_name => 'Maria', :enquirer_name => 'Uncle'

      expect(child.potential_matches.size).to eq(1)
      expect(child.potential_matches).to include(enquiry1)
      expect(child.potential_matches).to_not include(enquiry2)
    end

    it 'should not return matches marked as confirmed' do
      child = create :child, :name => 'Eduardo'
      enquiry1 = create :enquiry, :child_name => 'Eduardo', :enquirer_name => 'Aunt'
      enquiry2 = create :enquiry, :child_name => 'Eduardo', :enquirer_name => 'Uncle'

      expect(child.potential_matches.size).to eq(2)
      expect(child.potential_matches).to include(enquiry1, enquiry2)

      pm = PotentialMatch.first
      pm.confirmed = true
      pm.save

      expect(child.potential_matches.size).to eq(1)
      expect(child.potential_matches).to include(enquiry1)
      expect(child.potential_matches).to_not include(enquiry2)
    end

    it 'should not return matches marked as invalid' do
      child = create :child, :name => 'Eduardo'
      enquiry1 = create :enquiry, :child_name => 'Eduardo', :enquirer_name => 'Aunt'
      enquiry2 = create :enquiry, :child_name => 'Eduardo', :enquirer_name => 'Uncle'

      expect(child.potential_matches.size).to eq(2)
      expect(child.potential_matches).to include(enquiry1, enquiry2)

      pm = PotentialMatch.first
      pm.marked_invalid = true
      pm.save

      expect(child.potential_matches.size).to eq(1)
      expect(child.potential_matches).to include(enquiry1)
      expect(child.potential_matches).to_not include(enquiry2)
    end
  end

  describe '#find_matching_enquiries' do
    before :each do
      PotentialMatch.all.each { |pm| pm.destroy }
    end

    it 'should be triggered after save' do
      enquiry = build(:enquiry, :child_name => 'Eduardo')
      allow(MatchService).to receive(:search_for_matching_enquiries).and_return(enquiry.id => '0.9')
      child = create(:child, :name => 'Eduardo')

      expect(PotentialMatch.count).to eq(1)
      expect(PotentialMatch.first.child_id).to eq(child.id)
      expect(PotentialMatch.first.enquiry_id).to eq(enquiry.id)
      expect(PotentialMatch.first.score).to eq('0.9')
    end
  end

  describe '.build_text_fields_for_solar' do
    it 'should not use searchable fields from the wrong form' do
      child_form = create :form, :name => Child::FORM_NAME
      field1 = build :text_field
      create :form_section, :form => child_form, :fields => [field1]
      enquiry_form = create :form, :name => Enquiry::FORM_NAME
      field2 = build :text_field
      create :form_section, :form => enquiry_form, :fields => [field2]
      fields = Child.build_text_fields_for_solar
      expect(fields).to_not include(field2.name)
      expect(fields).to include(field1.name)
    end
  end

  private

  def create_child(name, options = {})
    options.merge!('name' => name, 'last_known_location' => 'new york', 'created_by' => 'me', 'created_organisation' => 'stc')
    create(:child, options)
  end

  def create_duplicate(parent)
    duplicate = Child.create(:name => 'dupe')
    duplicate.mark_as_duplicate(parent['short_id'])
    duplicate.save!
    duplicate
  end

  def create_child_with_created_by(created_by, options = {})
    user = User.new(:user_name => created_by, :organisation => 'UNICEF')
    Child.new_with_user_name user, options
  end
end
