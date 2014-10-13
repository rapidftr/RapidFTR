require 'spec_helper'

describe PotentialMatch, :type => :model do
  context 'Potential match state transitions' do
    let!(:child) { create :child }
    let!(:enquiry) { create :enquiry }
    let(:match) { PotentialMatch.create(:enquiry => enquiry, :child => child) }

    before :each do
      allow(User).to receive(:current_user).and_return(build(:user))
    end

    context 'from POTENTIAL' do
      context 'to CONFIRMED' do
        before :each do
          match.mark_as_confirmed
          match.save
          child.reload
          enquiry.reload
        end

        it 'should add history to enquiry when confirming' do
          changes = enquiry.histories[1]['changes']
          expect(changes).to eq('match' => {'from' => 'POTENTIAL', 'to' => 'CONFIRMED'})
        end

        it 'should add history to child when confirming' do
          changes = child.histories[1]['changes']
          expect(changes).to eq('match' => {'from' => 'POTENTIAL', 'to' => 'CONFIRMED'})
        end
      end
    end

    context 'from CONFIRMED' do
      context 'to POTENTIAL' do
        before :each do
          match.mark_as_confirmed
          match.save
          match.mark_as_potential_match
          match.save
          enquiry.reload
          child.reload
        end

        it 'should add history to enquiry when confirming' do
          changes = enquiry.histories[2]['changes']
          expect(changes).to eq('match' => {'from' => 'CONFIRMED', 'to' => 'POTENTIAL'})
        end

        it 'should add history to child when confirming' do
          changes = child.histories[2]['changes']
          expect(changes).to eq('match' => {'from' => 'CONFIRMED', 'to' => 'POTENTIAL'})
        end
      end
    end
  end
end
