require 'spec_helper'

describe PotentialMatchesController, :type => :controller do

  before :each do
    FormSection.all.each { |fs| fs.destroy }
    fake_field_worker_login
    @child = create(:child, :name => 'John Doe', :gender => 'male')
    form = create(:form, :name => Enquiry::FORM_NAME)
    @form_section = create(:form_section, :name => 'enquiry_criteria', :form => form, :fields => [build(:text_field, :name => 'enquirer_name')])
    allow(MatchService).to receive(:search_for_matching_children).and_return([@child])
    @enquiry = create(:enquiry, :enquirer_name => 'Foo Bar')
    allow(controller.current_ability).to receive(:can?).with(:update, Enquiry).and_return(true)
  end

  describe 'destroy' do
    it 'should remove child id from potential matches ' do
      expect(@enquiry.potential_matches.length).to eq 1
      delete :destroy, :enquiry_id => @enquiry.id, :id => @child.id

      @enquiry.reload
      expect(@enquiry.potential_matches.length).to eq 0
    end

    it 'should redirect to potential matches section of enquiry page after marking child as not matching' do
      delete :destroy, :enquiry_id => @enquiry.id, :id => @child.id

      expect(response).to redirect_to "/enquiries/#{@enquiry.id}#tab_potential_matches"
    end

  end
end
