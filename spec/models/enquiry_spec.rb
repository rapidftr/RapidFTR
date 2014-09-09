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

      it 'should update potential matches with new matches whenever an enquiry is edited' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'john doe', 'created_by' => 'me', :location => 'kampala', 'created_organisation' => 'stc')
        child3 = Child.create(:name => 'foo bar', 'created_by' => 'me', :gender => 'male', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches).to include(child1, child2)

        enquiry.gender = 'male'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches).to include(child1, child2, child3)
      end

      it 'should sort the results based on solr scores' do
        child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches).to include(child1, child2)
      end

      it 'should not return matches marked as invalid' do
        child1 = build(:child, :name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = build(:child, :name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')
        allow(MatchService).to receive(:search_for_matching_children).and_return([child1, child2])

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
        expect(enquiry.potential_matches.size).to eq(2)

        pm = PotentialMatch.first
        pm.mark_as_invalid
        pm.save

        expect(enquiry.potential_matches.size).to eq(1)
      end

      it 'should contain potential matches given one matching child' do
        child = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        enquiry = Enquiry.create!(:enquirer_name => 'Kisitu', :name => 'eduardo')

        expect(enquiry.criteria).not_to be_empty
        expect(enquiry.potential_matches).not_to be_empty
        expect(enquiry.potential_matches).to eq([child])
      end

      it 'should contain multiple potential matches given multiple matching children' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'john doe', 'created_by' => 'me', :location => 'kampala', 'created_organisation' => 'stc')
        child3 = Child.create(:name => 'foo bar', 'created_by' => 'me', :gender => 'male', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'kampala', :gender => 'male', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches).to include(child1, child2, child3)
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

      it 'should not use empty fields' do
        fields = {'name' => '   ', 'nationality' => 'Ugandan'}
        enquiry = Enquiry.new(fields)
        enquiry.save!

        expect(enquiry.criteria).to eq('nationality' => 'Ugandan')
        expect(enquiry.criteria['name']).to be_nil
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

    describe 'find_matching_children' do
      after :each do
        PotentialMatch.all.each { |pm| pm.destroy }
      end

      it 'should not have potential matches if no criteria' do
        enquiry = build :enquiry, :criteria => {}
        enquiry.find_matching_children
        expect(enquiry.potential_matches).to eq([])
      end

      it 'should create potential match when enquiry that has a match is created' do
        child = build(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return([child])
        enquiry = build(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children

        expect(PotentialMatch.count).to eq 1
        expect(PotentialMatch.first.child_id).to eq child.id
        expect(PotentialMatch.first.enquiry_id).to eq enquiry.id
      end
    end

    describe '.with_child_potential_matches' do
      before :each do
        PotentialMatch.all.each { |pm| pm.destroy }
      end

      it 'should only return enquiries with potential matches' do
        enquiry_x = build(:enquiry, :id => 'enquiry_id_x')
        enquiry_y = build(:enquiry, :id => 'enquiry_id_y')
        enquiry_z = build(:enquiry, :id => 'enquiry_id_z')
        expect(Enquiry).to receive(:find).with(enquiry_x.id).and_return(enquiry_x)
        expect(Enquiry).to receive(:find).with(enquiry_y.id).and_return(enquiry_y)
        expect(Enquiry).to_not receive(:find).with(enquiry_z.id)
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_x'
        PotentialMatch.create :enquiry_id => 'enquiry_id_y', :child_id => 'child_id_y'
        PotentialMatch.create :enquiry_id => 'enquiry_id_z', :child_id => 'child_id_y', :marked_invalid => true

        enquiries = Enquiry.with_child_potential_matches
        expect(enquiries.size).to eq(2)
        expect(enquiries).to include(enquiry_x, enquiry_y)
      end

      it 'should not return duplicate enquiries' do
        enquiry_x = build(:enquiry, :id => 'enquiry_id_x')
        expect(Enquiry).to receive(:find).with(enquiry_x.id).and_return(enquiry_x)
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_x'
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_y'

        enquiries = Enquiry.with_child_potential_matches
        expect(enquiries.size).to eq(1)
        expect(enquiries).to include(enquiry_x)
      end

      it 'should not return invalid matches' do
        enquiry_x = build(:enquiry, :id => 'enquiry_id_x')
        expect(Enquiry).to_not receive(:find).with(enquiry_x.id)
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_x', :marked_invalid => true

        enquiries = Enquiry.with_child_potential_matches
        expect(enquiries.size).to eq(0)
      end

      it 'should paginate results' do
        10.times do |i|
          enquiry = build(:enquiry, :id => "enquiry_#{i}")
          allow(Enquiry).to receive(:find).with(enquiry.id).and_return(enquiry)
          PotentialMatch.create :enquiry_id => "enquiry_#{i}", :child_id => i.to_s
        end

        enquiries = Enquiry.with_child_potential_matches :per_page => 5
        expect(enquiries.size).to eq(5)
        expect(enquiries.total_pages).to eq(2)
      end
    end

    describe 'strip_whitespaces' do
      it 'should strip whitespaces' do
        enquiry = build :enquiry, :child_name => '  childs name    '
        enquiry.send :strip_whitespaces
        expect(enquiry['child_name']).to eq('childs name')
      end

      it 'should be run before validation' do
        enquiry = build :enquiry, :child_name => '  childs name  '
        expect(enquiry['child_name']).to eq('  childs name  ')
        enquiry.run_callbacks :validation
        expect(enquiry['child_name']).to eq('childs name')
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
