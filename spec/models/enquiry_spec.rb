require 'spec_helper'

describe Enquiry, :type => :model do

  before :each do
    Enquiry.all.each { |e| e.destroy }
    Sunspot.remove_all!(Child)

    allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
  end

  describe 'validation' do
    it 'should fail to validate if all fields are nil' do
      enquiry = Enquiry.new
      allow(FormSection).to receive(:all_visible_child_fields_for_form).and_return [Field.new(:type => 'numeric_field', :name => 'height', :display_name => 'height')]
      expect(enquiry).not_to be_valid
      expect(enquiry.errors[:validate_has_at_least_one_field_value]).to eq(['Please fill in at lease one field or upload a file'])
    end

    describe '#update_from_properties' do
      it 'should update the enquiry' do
        enquiry = create_enquiry_with_created_by('jdoe', :enquirer_name => 'Vivek', :place => 'Kampala')
        properties = {:enquirer_name => 'DJ', :place => 'Kampala'}
        enquiry.update_from(properties)

        expect(enquiry.enquirer_name).to eq('DJ')
        expect(enquiry['place']).to eq('Kampala')
      end
    end

    describe 'new_with_user_name' do
      it 'should create a created_by field with the user name and organisation' do
        enquiry = create_enquiry_with_created_by('jdoe', {'some_field' => 'some_value'}, 'Jdoe-organisation')
        expect(enquiry['created_by']).to eq('jdoe')
        expect(enquiry['created_organisation']).to eq('Jdoe-organisation')

      end
    end

    describe 'timestamp' do
      it 'should create a posted_at and created_at fields with the current date' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
        enquiry = create_enquiry_with_created_by('some_user', 'some_field' => 'some_value')
        expect(enquiry['posted_at']).to eq('2010-01-22 14:05:00UTC')
        expect(enquiry['created_at']).to eq('2010-01-22 14:05:00UTC')
      end

      it 'should use the supplied created at value' do
        enquiry = create_enquiry_with_created_by('some_user', 'some_field' => 'some_value', 'created_at' => '2010-01-14 14:05:00UTC')
        expect(enquiry['created_at']).to eq('2010-01-14 14:05:00UTC')
      end
    end

    describe 'updated_at' do
      before :each do
        FormSection.all.each { |fs| fs.destroy }
        form = create(:form, :name => Enquiry::FORM_NAME)
        enquirer_name_field = build(:field, :name => 'enquirer_name')
        child_name_field = build(:field, :name => 'child_name')
        create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field])
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 14, 05, 0))
        @enquiry = Enquiry.create(:enquirer_name => 'John doe', :child_name => 'any child')
      end

      it 'should add updated_at field when creating enquiry' do
        expect(@enquiry['updated_at']).to eq('2010-01-22 14:05:00UTC')
      end

      it 'should reflect new date when enquiry is updated' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 15, 05, 0))

        enquiry = Enquiry.first
        enquiry.update_attributes(:enquirer_name => 'David Jones')

        expect(enquiry['updated_at']).to eq('2010-01-22 15:05:00UTC')
      end

      it 'should reflect new date when potential_matches are updated' do
        allow(Clock).to receive(:now).and_return(Time.utc(2010, 'jan', 22, 15, 05, 0))

        @enquiry[:potential_matches] << 'matching_child_id'
        @enquiry.save!
        expect(@enquiry['updated_at']).to eq('2010-01-22 15:05:00UTC')
      end
    end

    describe 'potential_matches', :solr => true do

      before :each do
        reset_couchdb!
        Sunspot.setup(Child) do
          text :location
          text :name
          text :gender
        end
        form = create :form, :name => Enquiry::FORM_NAME

        create :form_section, :name => 'test_form', :fields => [
          build(:text_field, :name => 'name'),
          build(:text_field, :name => 'location'),
          build(:text_field, :name => 'gender'),
          build(:text_field, :name => 'enquirer_name')
        ], :form => form
      end

      it 'should be an empty array when enquiry is created' do
        enquiry = Enquiry.new
        expect(enquiry.potential_matches).to eq([])
      end

      it 'should contain potential matches given one matching child' do
        child = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        enquiry = Enquiry.create!(:enquirer_name => 'Kisitu', :name => 'eduardo')

        expect(enquiry.criteria).not_to be_empty
        expect(enquiry.potential_matches).not_to be_empty
        expect(enquiry.potential_matches).to eq([child.id])
      end

      it 'should not fail when enquiry has no potential matches' do
        enquiry = Enquiry.create!(:name => 'does not exist', :enquirer_name => 'Kisitu')
        expect(enquiry.potential_matches).to be_empty
      end

      it 'should contain multiple potential matches given multiple matching children' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'john doe', 'created_by' => 'me', :location => 'kampala', 'created_organisation' => 'stc')
        child3 = Child.create(:name => 'foo bar', 'created_by' => 'me', :gender => 'male', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'kampala', :gender => 'male', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches).to include(child1.id, child2.id, child3.id)
      end

      it 'should assure that potential_matches contains no duplicates' do
        child1 = Child.create(:name => 'eduardo aquiles', :gender => 'male', 'created_by' => 'me', 'created_organisation' => 'stc')
        enquiry = Enquiry.create!(:enquirer_name => 'Kisitu', :name => 'eduardo')

        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches).to eq([child1.id])

        enquiry.gender = 'male'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches).to eq([child1.id])
      end

      it 'should update potential matches with new matches whenever an enquiry is edited' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'john doe', 'created_by' => 'me', :location => 'kampala', 'created_organisation' => 'stc')
        child3 = Child.create(:name => 'foo bar', 'created_by' => 'me', :gender => 'male', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches).to include(child1.id, child2.id)

        enquiry.gender = 'male'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches).to include(child1.id, child2.id, child3.id)
      end

      it 'should remove id that dont match anymore whenever criteria changes' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches).to eq([child1.id])

        enquiry.name = 'John'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(0)
        expect(enquiry.potential_matches).to eq([])
      end

      it 'should keep only matching ids when criteria changes' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'foo bar', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches).to include(child1.id, child2.id)

        enquiry.name = 'John'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches).to eq([child2.id])
      end

      it 'should sort the results based on solr scores' do
        child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches).to eq([child1.id, child2.id])
      end

      it 'should remove id specified as not matching during save' do
        child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
        expect(enquiry.potential_matches.size).to eq(2)

        enquiry.ids_marked_as_not_matching << child1.id
        enquiry.save

        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches.first).to eq(child2.id)
      end

      it 'should not include child records marked as not matching in potential_matches when enquiry has not been edited' do
        child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')
        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
        expect(enquiry.potential_matches.size).to eq(2)

        enquiry.ids_marked_as_not_matching << child1.id
        enquiry.save
        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.potential_matches.first).to eq(child2.id)

        enquiry.ids_marked_as_not_matching << child2.id
        enquiry.save
        expect(enquiry.potential_matches.size).to eq(0)        
      end

      describe '#ids_marked_as_not_matching' do
        before :each do
          @child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
          @child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')
          @enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
        end

        it 'should empty when an enquiry is new' do
          expect(@enquiry.ids_marked_as_not_matching.length).to eq(0)
        end

        it 'should append ids' do
          @enquiry.ids_marked_as_not_matching << @child1.id

          expect(@enquiry.ids_marked_as_not_matching.length).to eq(1)
          expect(@enquiry.ids_marked_as_not_matching.first).to eq(@child1.id)
        end

        it 'should delete all child record ids marked as not matching' do
          @enquiry.ids_marked_as_not_matching << @child1.id
          @enquiry.ids_marked_as_not_matching << @child2.id
          expect(@enquiry.ids_marked_as_not_matching.length).to eq 2

          @enquiry.clear_ids_marked_as_not_matching()

          expect(@enquiry.ids_marked_as_not_matching.length).to eq(0)
        end
      end

      describe 'match_updated_at', :solr => true do

        before do
          allow(Clock).to receive(:now).and_return(Time.utc(2013, 'jan', 01, 00, 00, 0))
          Child.create(:name => 'Eduardo aquiles', :location => 'Kyangwali', 'created_by' => 'One', 'created_organisation' => 'stc')
          Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'Two', 'created_organisation' => 'stc')
        end

        after do
          Enquiry.all.each { |enquiry| enquiry.destroy }
          Child.all.each { |child| child.destroy }
        end

        it 'should update match_updated_at timestamp when new matching children are found on creation of an Enquiry' do
          enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
          expect(enquiry.match_updated_at).to eq(Time.utc(2013, 'jan', 01, 00, 00, 0).to_s)
        end

        it 'should not update match_updated_at if there are no matching children records on creation of an Enquiry' do
          enquiry = Enquiry.create!(:criteria => {'name' => 'Dennis', 'location' => 'Space'}, :enquirer_name => 'Kisitu')
          expect(enquiry.match_updated_at).to eq('')
        end

        it 'should update match_updated_at timestamp when new matching children are found on update of an Enquiry' do
          enquiry = Enquiry.create!(:name => 'Eduardo', :enquirer_name => 'Kisitu')
          expect(enquiry.match_updated_at).to eq(Time.utc(2013, 'jan', 01, 00, 00, 0).to_s)
          expect(enquiry.potential_matches.size).to eq(1)

          allow(Clock).to receive(:now).and_return(Time.utc(2013, 'jan', 02, 00, 00, 0))
          enquiry.location = 'Kampala'
          enquiry.save!
          expect(enquiry.match_updated_at).to eq(Time.utc(2013, 'jan', 02, 00, 00, 0).to_s)
          expect(enquiry.potential_matches.size).to eq(2)
        end
      end
    end
    describe 'all_enquires' do
      it 'should return a list of all enquiries' do
        save_valid_enquiry('user2', 'enquiry_id' => 'id2', 'criteria' => {'location' => 'Kampala'}, 'enquirer_name' => 'John', 'reporter_details' => {'location' => 'Kampala'})
        save_valid_enquiry('user1', 'enquiry_id' => 'id1', 'criteria' => {'location' => 'Kampala'}, 'enquirer_name' => 'John', 'reporter_details' => {'location' => 'Kampala'})
        expect(Enquiry.all.all.size).to eq(2)
      end
    end

    describe 'search_by_match_updated_since' do
      it 'should fetch enquiries with match_updated_at time that is at or after timestamp' do
        save_valid_enquiry('user2', 'enquiry_id' => 'id2', 'criteria' => {'location' => 'Kampala'}, 'enquirer_name' => 'John', 'reporter_details' => {'location' => 'Kampala'}, 'match_updated_at' => '2013-09-18 06:42:12UTC')
        save_valid_enquiry('user1', 'enquiry_id' => 'id1', 'criteria' => {'location' => 'Kampala'}, 'enquirer_name' => 'John', 'reporter_details' => {'location' => 'Kampala'}, 'match_updated_at' => '2013-07-18 06:42:12UTC')

        expect(Enquiry.search_by_match_updated_since(DateTime.parse('2013-09-18 05:42:12UTC')).size).to eq(1)
        expect(Enquiry.search_by_match_updated_since(DateTime.parse('2013-09-18 06:42:12UTC')).size).to eq(1)
      end
    end

    describe 'create_criteria' do
      before :each do
        reset_couchdb!

        form = create :form, :name => Enquiry::FORM_NAME

        create :form_section, :name => 'test_form', :fields => [
          build(:text_field, :name => 'name'),
          build(:text_field, :name => 'location'),
          build(:text_field, :name => 'nationality'),
          build(:text_field, :name => 'enquirer_name'),
          build(:numeric_field, :name => 'age'),
          build(:text_field, :name => 'parent_name', :matchable => false),
          build(:text_field, :name => 'sibling_name', :matchable => false)
        ], :form => form
      end

      it 'should generate criteria before saving' do
        fields = {'name' => 'Eduardo', 'nationality' => 'Ugandan', 'enquirer_name' => 'Subhas', 'age' => '10', 'location' => 'Kampala'}
        enquiry = Enquiry.new(fields)
        enquiry.save!

        expect(enquiry.criteria).to eq(fields)
      end

      it 'should generate criteria before saving for filled in fields' do
        fields = {'name' => 'Eduardo', 'nationality' => 'Ugandan', 'enquirer_name' => 'Subhas', 'age' => nil, 'location' => 'Kampala'}
        enquiry = Enquiry.new(fields)
        enquiry.save!

        expect(enquiry.criteria).to eq(fields.keep_if { |_key, value| !value.nil? })
      end

      it 'should only use matchable fields' do
        fields = {'name' => 'Eduardo', 'nationality' => 'Ugandan', 'sibling_name' => 'sister', 'parent_name' => 'father'}
        enquiry = Enquiry.new(fields)
        enquiry.save!

        expect(enquiry.criteria).to eq('name' => 'Eduardo', 'nationality' => 'Ugandan')
      end
    end

    describe '.update_all_child_matches' do
      it 'should update child matches for all enquiries' do
        enquiry1 = build(:enquiry)
        enquiry2 = build(:enquiry)
        enquiries = [enquiry1, enquiry2]

        expect(Enquiry).to receive(:all).and_return(enquiries)
        expect(enquiry1).to receive(:find_matching_children)
        expect(enquiry2).to receive(:find_matching_children)

        Enquiry.update_all_child_matches
      end
    end

    private

    def create_enquiry_with_created_by(created_by, options = {}, organisation = 'UNICEF')
      user = User.new(:user_name => created_by, :organisation => organisation)
      Enquiry.new_with_user_name(user, options)
    end

    def save_valid_enquiry(user, options = {}, organisation = 'UNICEF')
      enquiry = create_enquiry_with_created_by(user, options, organisation)
      enquiry.save!
    end
  end
end
