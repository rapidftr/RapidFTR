require 'spec_helper'

describe Enquiry, :type => :model do

  before :each do
    Enquiry.all.each { |e| e.destroy }
    Sunspot.remove_all!(Child)

    allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
    allow(SystemVariable).to receive(:find_by_name).and_return(double(:value => '0.00'))
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

    describe 'update_histories' do

      before :each do
        FormSection.all.each { |fs| fs.destroy }
        form = create(:form, :name => Enquiry::FORM_NAME)
        enquirer_name_field = build(:field, :name => 'enquirer_name')
        child_name_field = build(:field, :name => 'child_name')
        create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [enquirer_name_field, child_name_field])

        Timecop.freeze(Date.today)
        @enquiry = Enquiry.create(:enquirer_name => 'John doe', :child_name => 'any child')
      end

      it 'should add history for updated fields on enquiry' do
        @enquiry.update_attributes(:enquirer_name => 'David Jones')
        histories = @enquiry.histories

        expect(histories.size).to eq(2)
        expect(histories.first['changes']['enquirer_name']['from']).to eq('John doe')
        expect(histories.first['changes']['enquirer_name']['to']).to eq('David Jones')
      end

      it 'should merge the histories of the given record with the current record if the update at of the current record is greater than that of the given record.' do
        Timecop.freeze(Date.today + 1)
        @enquiry.update_attributes(:enquirer_name => 'David Jones')

        histories = @enquiry.histories

        expect(histories.size).to eq(2)

        Timecop.freeze(Date.today + 2)
        given_histories = histories.concat([JSON.parse("{\"user_name\":\"rapidftr\",\"datetime\":\"2012-01-01 00:00:02UTC\",\"changes\":{\"enquirer_name\":{\"to\":\"new\",\"from\":\"old\"}}}")])
        given_properties = {'child_name' => 'Ann', 'updated_at' => "#{RapidFTR::Clock.current_formatted_time}", 'histories' => given_histories}

        @enquiry.update_properties_with_user_name 'rapidftr', nil, nil, nil, given_properties
        @enquiry.save!

        histories = @enquiry.histories

        expect(histories.size).to eq(4)
        expect(histories.first['changes']['child_name']['from']).to eq('any child')
        expect(histories.first['changes']['child_name']['to']).to eq('Ann')

        Timecop.return
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

    describe '#potential_matches', :solr => true do

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
        expect(enquiry.potential_matches.map(&:child)).to include(child1, child2)

        enquiry.gender = 'male'
        enquiry.save!

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches.map(&:child)).to include(child1, child2, child3)
      end

      it 'should sort the results based on solr scores' do
        child1 = Child.create(:name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(2)
        expect(enquiry.potential_matches.map(&:child)).to include(child1, child2)
      end

      it 'should not return matches marked as confirmed' do
        child1 = build(:child, :name => 'Eduardo aquiles', :location => 'Kampala', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = build(:child, :name => 'Batman', :location => 'Kampala', 'created_by' => 'not me', 'created_organisation' => 'stc')
        allow(MatchService).to receive(:search_for_matching_children).and_return([child1, child2])

        enquiry = Enquiry.create!(:name => 'Eduardo', :location => 'Kampala', :enquirer_name => 'Kisitu')
        expect(enquiry.potential_matches.size).to eq(2)

        pm = PotentialMatch.first
        pm.mark_as_confirmed
        pm.save

        expect(enquiry.potential_matches.size).to eq(1)
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
        expect(enquiry.potential_matches.map(&:child)).to eq([child])
      end

      it 'should contain multiple potential matches given multiple matching children' do
        child1 = Child.create(:name => 'eduardo aquiles', 'created_by' => 'me', 'created_organisation' => 'stc')
        child2 = Child.create(:name => 'john doe', 'created_by' => 'me', :location => 'kampala', 'created_organisation' => 'stc')
        child3 = Child.create(:name => 'foo bar', 'created_by' => 'me', :gender => 'male', 'created_organisation' => 'stc')

        enquiry = Enquiry.create!(:name => 'eduardo', :location => 'kampala', :gender => 'male', :enquirer_name => 'Kisitu')

        expect(enquiry.potential_matches.size).to eq(3)
        expect(enquiry.potential_matches.map(&:child)).to include(child1, child2, child3)
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
        reset_couchdb!
      end

      it 'should not have potential matches if no criteria' do
        enquiry = build :enquiry, :criteria => {}
        enquiry.find_matching_children
        expect(enquiry.potential_matches).to eq([])
      end

      it 'should create potential match when enquiry that has a match is created' do
        child = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child.id => '0.8')
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children

        expect(PotentialMatch.count).to eq 1
        expect(PotentialMatch.first.child_id).to eq child.id
        expect(PotentialMatch.first.enquiry_id).to eq enquiry.id
        expect(PotentialMatch.first.score).to eq '0.8'
      end

      it 'should order the potential matches by score' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children

        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 4
        expect(potential_matches.first.score).to eq '2.5'
        expect(potential_matches.last.score).to eq '0.2'
      end

      it 'should limit the potential matches according to the threshold number set' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)

        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))

        enquiry = create(:enquiry, :criteria => {:a => :b})

        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.5'
        expect(potential_matches.last.score).to eq '1.0'
      end

      it 'should mark as deleted the previous potential matches whose updated score is less than the threshold.' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))

        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.5'

        child5 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '0.1', child3.id => '2.9', child4.id => '0.2', child5.id => '2.1')
        enquiry.update_attributes(:name => 'charles')
        enquiry.find_matching_children

        deleted_potential_matches = PotentialMatch.by_enquiry_id_and_status.key([enquiry.id, PotentialMatch::DELETED])
        expect(deleted_potential_matches.count).to eq 1
        expect(deleted_potential_matches.map(&:child_id)).to include(child2.id)
        expect(enquiry.potential_matches.count).to eq 2
      end

      it 'should not mark as deleted previous potential matches that have been marked as confirmed.' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.5'

        confirmed_match = potential_matches.last
        confirmed_match.mark_as_confirmed
        confirmed_match.save!

        child5 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child3.id => '2.9', child4.id => '0.2', child5.id => '2.1')
        enquiry.update_attributes(:name => 'charles')
        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches

        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.9'
        expect(potential_matches.map(&:child_id)).to include(child3.id, child5.id)

        confirmed_match = PotentialMatch.by_enquiry_id_and_status.key([enquiry.id, PotentialMatch::CONFIRMED]).first
        expect(confirmed_match.child_id).to eq(child2.id)
        expect(confirmed_match.deleted?).to eq(false)
      end

      it 'should not mark as deleted previous matches that have been marked as not matching' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.5'

        invalid_match = potential_matches.last
        invalid_match.mark_as_invalid
        invalid_match.save!

        child5 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child3.id => '2.9', child4.id => '0.2', child5.id => '2.1')
        enquiry.update_attributes(:name => 'charles')
        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches

        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.9'
        expect(potential_matches.map(&:child_id)).to include(child3.id, child5.id)

        invalid_match = PotentialMatch.by_enquiry_id_and_status.key([enquiry.id, PotentialMatch::INVALID]).first
        expect(invalid_match.child_id).to eq(child2.id)
        expect(invalid_match.deleted?).to eq(false)
      end

      it 'should unmark deleted previous potential matches when they appear in the hits from solr.' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        child4 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5', child4.id => '0.2')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))

        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 2
        expect(potential_matches.first.score).to eq '2.5'

        child5 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '0.1', child3.id => '2.9', child4.id => '0.2', child5.id => '2.1')
        enquiry.update_attributes(:name => 'charles')
        enquiry.find_matching_children

        deleted_potential_matches = PotentialMatch.by_enquiry_id_and_status.key([enquiry.id, PotentialMatch::DELETED])
        expect(deleted_potential_matches.count).to eq 1
        expect(deleted_potential_matches.map(&:child_id)).to include(child2.id)
        expect(enquiry.potential_matches.count).to eq 2

        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '2.0', child3.id => '2.9', child4.id => '0.2', child5.id => '2.1')
        enquiry.update_attributes(:name => 'children')
        enquiry.find_matching_children

        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq 3
        expect(potential_matches.map(&:child_id)).to include(child2.id)
      end
    end

    describe 'marking enquiries as reunited' do
      before :each do
        Child.all.each(&:destroy)
        PotentialMatch.all.each(&:destroy)
        Enquiry.all.each(&:destroy)
        FormSection.all.each(&:destroy)
        Form.all.each(&:destroy)
      end

      it 'should return reunited match' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)

        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq(2)

        confirmed_match = potential_matches.first
        confirmed_match.mark_as_confirmed
        confirmed_match.save!

        child3.reunited = true
        child3.save!

        enquiry = Enquiry.get(enquiry.id)
        expect(enquiry.reunited).to be true
        expect(enquiry.reunited_match.child_id).to eq(child3.id)
      end

      it 'should mark an enquiry as reunited when child is marked as reunited.' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)

        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq(2)

        confirmed_match = potential_matches.first
        confirmed_match.mark_as_confirmed
        confirmed_match.save!

        child3.reunited = true
        child3.save!

        enquiry = enquiry.reload
        expect(enquiry['reunited']).to be true
      end

      it 'should not return a reunited enquiry as a potential match for other children' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)
        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq(2)

        confirmed_match = potential_matches.first
        confirmed_match.mark_as_confirmed
        confirmed_match.save!

        child3.reunited = true
        child3.save!
        enquiry.reload

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(enquiry['reunited']).to be true
        expect(potential_matches.count).to eq 0
      end
    end

    describe 'unmarking enquiries as reunited.' do
      before :each do
        Child.all.each(&:destroy)
        PotentialMatch.all.each(&:destroy)
        Enquiry.all.each(&:destroy)
        FormSection.all.each(&:destroy)
        Form.all.each(&:destroy)
      end

      it 'should unmark an enquiry as reunited when child is unmarked as reunited.' do
        child1 = create(:child)
        child2 = create(:child)
        child3 = create(:child)

        allow(MatchService).to receive(:search_for_matching_children).and_return(child1.id => '0.5', child2.id => '1.0', child3.id => '2.5')
        allow(SystemVariable).to receive(:find_by_name).and_return(SystemVariable.new(:name => 'THRESHOLD', :value => '1.0'))
        enquiry = create(:enquiry, :criteria => {:a => :b})

        enquiry.find_matching_children
        potential_matches = enquiry.potential_matches
        expect(potential_matches.count).to eq(2)

        confirmed_match = potential_matches.first
        confirmed_match.mark_as_confirmed
        confirmed_match.save!

        child3.reunited = true
        child3.save!
        child3 = Child.get(child3.id)

        enquiry = Enquiry.get(enquiry.id)
        expect(enquiry['reunited']).to be true
        expect(enquiry.potential_matches.count).to eq(0)
        child3.reunited = false
        child3.save!

        enquiry = Enquiry.get(enquiry.id)
        expect(enquiry['reunited']).to be false
        expect(enquiry.potential_matches.size).to eq(1)
        expect(enquiry.confirmed_match).not_to be_nil
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
        PotentialMatch.create :enquiry_id => 'enquiry_id_z', :child_id => 'child_id_y', :status => PotentialMatch::INVALID

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

      it 'should not return confirmed matches' do
        enquiry_x = build(:enquiry, :id => 'enquiry_id_x')
        expect(Enquiry).to_not receive(:find).with(enquiry_x.id)
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_x', :status => PotentialMatch::CONFIRMED

        enquiries = Enquiry.with_child_potential_matches
        expect(enquiries.size).to eq(0)
      end

      it 'should not return invalid matches' do
        enquiry_x = build(:enquiry, :id => 'enquiry_id_x')
        expect(Enquiry).to_not receive(:find).with(enquiry_x.id)
        PotentialMatch.create :enquiry_id => 'enquiry_id_x', :child_id => 'child_id_x', :status => PotentialMatch::INVALID

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

    describe 'searchable_field_names' do
      it 'should include highlighted fields, short_id, and unique_identifier' do
        form = create :form, :name => Enquiry::FORM_NAME
        create :form_section, :form => form, :name => 'Basic Identity', :fields => [build(:field, :name => 'first_name', :highlighted => true)]

        expect(Enquiry.searchable_field_names).to eq ['first_name', :unique_identifier, :short_id]
      end
    end

    describe '#confirmed_match' do
      after :each do
        PotentialMatch.all.each { |pm| pm.destroy }
        Enquiry.all.each(&:destroy)
        Child.all.each(&:destroy)
      end

      it 'should return a confirmed match' do
        enquiry_x = create(:enquiry, :id => 'enquiry_id_x')
        child_x = create(:child, :id => 'child_id_x')

        PotentialMatch.create :enquiry_id => 'enquiry_id_x',
                              :child_id => 'child_id_x',
                              :status => PotentialMatch::CONFIRMED
        expect(enquiry_x.confirmed_match).to_not be_nil
        expect(enquiry_x.confirmed_match.child.id).to eq(child_x.id)
      end

      it 'should not return unconfirmed matches' do
        enquiry_x = create(:enquiry, :id => 'enquiry_id_x')
        create(:child, :id => 'child_id_x')
        PotentialMatch.create :enquiry_id => 'enquiry_id_x',
                              :child_id => 'child_id_x',
                              :status => PotentialMatch::POTENTIAL
        expect(Child).to_not receive(:get)
        expect(enquiry_x.confirmed_match).to be_nil
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
        fields = Enquiry.build_text_fields_for_solar
        expect(fields).to_not include(field1.name)
        expect(fields).to include(field2.name)
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
