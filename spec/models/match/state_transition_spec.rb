require 'spec_helper'

describe PotentialMatch, :type => :model do
  context 'Potential match state transitions' do
    before :each do
      allow(User).to receive(:current_user).and_return(build(:user))
    end

    shared_examples_for 'a status transition that triggers changelogs' do
      let!(:child) { create :child }
      let!(:enquiry) { create :enquiry }
      let(:match) do
        PotentialMatch.create(:enquiry => enquiry,
                              :child => child,
                              :status => old_status)
      end

      before :each do
        match.send(:mark_as_status, new_status)
        match.save
        child.reload
        enquiry.reload
      end

      it 'should update the child record with a changelong' do
        child_changes = child.histories.last['changes']
        expect(child_changes).to eq('match' => {'from' => old_status, 'to' => new_status})
      end

      it 'should update the enquiry record with a changelong' do
        enquiry_changes = enquiry.histories.last['changes']
        expect(enquiry_changes).to eq('match' => {'from' => old_status, 'to' => new_status})
      end
    end

    context 'from CONFIRMED' do
      let(:old_status) { PotentialMatch::CONFIRMED }
      let(:new_status) { 'anything' }
      it_behaves_like 'a status transition that triggers changelogs'
    end

    context 'from INVALID' do
      let(:old_status) { PotentialMatch::INVALID }
      let(:new_status) { 'anything' }
      it_behaves_like 'a status transition that triggers changelogs'
    end

    context 'from REUNITED' do
      let(:old_status) { PotentialMatch::REUNITED }
      let(:new_status) { 'anything' }
      it_behaves_like 'a status transition that triggers changelogs'

      context 'to POTENTIAL' do
        let!(:enquiry) { create :enquiry }
        let!(:child) { create :child }
        let(:match) { PotentialMatch.create :child => child, :enquiry => enquiry }

        before :each do
          child.update_attributes :reunited => true
          enquiry.reload
          enquiry.update_attributes :reunited => true
          match.update_attributes :status => PotentialMatch::REUNITED
        end

        it 'should update the enquiry as not reunited' do
          PotentialMatch.first.update_attributes :status => PotentialMatch::POTENTIAL
          enquiry.reload
          expect(enquiry).to_not be_reunited
        end

        it 'should transition other enquiry matches back to potential' do
          child2 = create :child
          match2 = PotentialMatch.create :child => child2,
                                         :enquiry => enquiry,
                                         :status => PotentialMatch::REUNITED_ELSEWHERE
          match.update_attributes :status => PotentialMatch::POTENTIAL
          match2.reload
          expect(match2.status).to eq(PotentialMatch::POTENTIAL)
        end
      end
    end

    context 'to CONFIRMED' do
      let(:old_status) { 'anything' }
      let(:new_status) { PotentialMatch::CONFIRMED }
      it_behaves_like 'a status transition that triggers changelogs'
    end

    context 'to INVALID' do
      let(:old_status) { 'anything' }
      let(:new_status) { PotentialMatch::INVALID }
      it_behaves_like 'a status transition that triggers changelogs'
    end

    context 'to REUNITED' do
      let(:old_status) { 'anything' }
      let(:new_status) { PotentialMatch::REUNITED }
      it_behaves_like 'a status transition that triggers changelogs'
    end
  end
end
