require 'spec_helper'

describe EnquiriesHelper, :type => :helper do
  describe 'enquiry_title' do
    before :each do
      reset_couchdb!
    end

    it 'should return short id and title field' do
      form = create :form, :name => Enquiry::FORM_NAME
      field = build :field, :name => 'title_field', :title_field => true, :highlighted => true
      create :form_section, :form => form, :fields => [field]
      enquiry = create :enquiry, :title_field => 'Enquiry Title'
      title = enquiry_title enquiry
      expect(title).to eq("Enquiry Title (#{enquiry.short_id})")
    end

    it 'should return only short id if no title field' do
      form = create :form, :name => Enquiry::FORM_NAME
      field = build :field, :name => 'title_field', :highlighted => true
      create :form_section, :form => form, :fields => [field]
      enquiry = create :enquiry, :title_field => 'Enquiry Title'
      title = enquiry_title enquiry
      expect(title).to eq("(#{enquiry.short_id})")
    end
  end
end
