require 'spec_helper'

describe PotentialMatch, :type => :model do
  before :all do
    PotentialMatch.all.each { |pm| pm.destroy }
    reset_couchdb!
  end

  describe 'create_matches_for' do
    before :each do
      reset_couchdb!
    end

    it 'should create potential match for an enquiry' do
      PotentialMatch.create_matches_for_enquiry '1a3efc', ['2e453c']

      expect(PotentialMatch.count).to eq 1
      expect(PotentialMatch.first.enquiry_id).to eq '1a3efc'
      expect(PotentialMatch.first.child_id).to eq '2e453c'
    end

    it 'should create potential matches for an enquiry' do
      PotentialMatch.create_matches_for_enquiry '1a3efc', %w(2e453c 2ef1g)

      expect(PotentialMatch.count).to eq 2
      potential_matches = PotentialMatch.all.all
      enquiry_ids = potential_matches.map(&:enquiry_id)
      expect(enquiry_ids).to include('1a3efc')
      child_ids = potential_matches.map(&:child_id)
      expect(child_ids).to include('2e453c', '2ef1g')
    end
  end

  describe 'uniqueness of enquiry id and child id' do
    before :each do
      PotentialMatch.all.each { |pm| pm.destroy }
    end

    it 'should assure that potential_matches contains no duplicates' do
      PotentialMatch.create :enquiry_id => 'enquiry_id', :child_id => 'child_id'
      potential_match = PotentialMatch.new :enquiry_id => 'enquiry_id', :child_id => 'child_id'
      expect(potential_match.save).to be(false)
      expect(potential_match.errors.messages).to include(:child_id => ['has already been taken'])
      expect(PotentialMatch.count).to be(1)
    end

    it 'should allow child_id to be the same if enquiry_id pairing is unique' do
      PotentialMatch.create :enquiry_id => 'enquiry_id_1', :child_id => 'child_id'
      PotentialMatch.create :enquiry_id => 'enquiry_id_2', :child_id => 'child_id'
      expect(PotentialMatch.count).to be(2)
    end

    it 'should allow enquiry_id to be the same if child_id pairing is unique' do
      PotentialMatch.create :enquiry_id => 'enquiry_id', :child_id => 'child_id_1'
      PotentialMatch.create :enquiry_id => 'enquiry_id', :child_id => 'child_id_2'
      expect(PotentialMatch.count).to be(2)
    end
  end

  describe 'potential_matches', :solr => true do

    before :each do
      allow(User).to receive(:find_by_user_name).and_return(double(:organisation => 'stc'))
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

    describe '#mark_as_invalid' do
      it 'should default marked_invalid as false' do
        potential_match = PotentialMatch.new :enquiry_id => 'enquiry id', :child_id => 'child id'
        expect(potential_match.marked_invalid).to be false
      end

      it 'should mark potential match as invalid' do
        potential_match = PotentialMatch.new :enquiry_id => 'enquiry id', :child_id => 'child id'
        potential_match.mark_as_invalid
        expect(potential_match.marked_invalid).to be true
      end
    end

    describe 'match_updated_at', :solr => true do

      before do
        allow(Clock).to receive(:now).and_return(Time.utc(2013, 'jan', 01, 00, 00, 0))
        Child.create(:name => 'Eduardo aquiles', :location => 'Kyangwali', :created_by => 'One', :created_organisation => 'stc')
        Child.create(:name => 'Batman', :location => 'Kampala', :created_by => 'Two', :created_organisation => 'stc')
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
        enquiry = Enquiry.create!(:criteria => {:name => 'Dennis', :location => 'Space'}, :enquirer_name => 'Kisitu')
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
end
