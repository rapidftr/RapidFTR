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

    it 'should return short id and multiple title fields' do
      form = create :form, :name => Enquiry::FORM_NAME
      field1 = build :field, :name => 'title_field1', :title_field => true, :highlighted => true
      field2 = build :field, :name => 'title_field2', :title_field => true, :highlighted => true
      create :form_section, :form => form, :fields => [field1, field2]
      enquiry = create :enquiry, :title_field1 => 'Title1', :title_field2 => 'Title2'
      title = enquiry_title enquiry
      expect(title).to eq("Title1 Title2 (#{enquiry.short_id})")
    end

    it 'should not return unnecessary spaces when fields arent filled in' do
      form = create :form, :name => Enquiry::FORM_NAME
      field1 = build :field, :name => 'title_field1', :title_field => true, :highlighted => true
      field2 = build :field, :name => 'title_field2', :title_field => true, :highlighted => true
      field3 = build :field, :name => 'title_field3', :title_field => true, :highlighted => true
      create :form_section, :form => form, :fields => [field1, field2, field3]
      enquiry = create :enquiry,
                       :title_field1 => 'Title1',
                       :title_field2 => nil,
                       :title_field3 => 'Title3'
      title = enquiry_title enquiry
      expect(title).to eq("Title1 Title3 (#{enquiry.short_id})")
    end

    it 'should return only short id if no title field' do
      form = create :form, :name => Enquiry::FORM_NAME
      field = build :field, :name => 'title_field', :highlighted => true
      create :form_section, :form => form, :fields => [field]
      enquiry = create :enquiry, :title_field => 'Enquiry Title'
      title = enquiry_title enquiry
      expect(title).to eq(enquiry.short_id)
    end

    it 'should return true if the enquiries are enabled' do
      SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => '1')
      expect(enquiries_enabled).to eq(true)
    end

    it 'should return false if the enquiries are disabled' do
      SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => '0')
      expect(enquiries_enabled).to eq(false)
    end
  end
end
