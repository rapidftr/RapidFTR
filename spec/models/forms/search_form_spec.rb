require 'spec_helper'

describe Forms::SearchForm, solr: true do

  before :all do
    create :form_section, fields: [
      build(:text_field, name: 'ftextfield'),
      build(:text_area_field, name: 'ftextarea'),
      build(:numeric_field, name: 'fnumeric'),
      build(:date_field, name: 'fdate'),
      build(:radio_button_field, name: 'fradiobutton', option_strings: ['radio 1', 'radio 2', 'radio 3']),
      build(:check_boxes_field, name: 'fcheckboxes', option_strings: ['check 1', 'check 2', 'check 3']),
      build(:select_box_field, name: 'fselectbox', option_strings: ['select 1', 'select 2', 'select 3']),
    ]

    @field_worker = create :field_worker_user
    @field_admin  = create :field_admin_user

    (1..3).each do |i|
      id = "child_#{i}"
      create :child, id: id, created_by: @field_worker.user_name,
        ftextfield: "#{id} textfield", ftextarea: "#{id} textarea", fnumeric: i.to_s,
        fradiobutton: "radio #{i%3}", fcheckboxes: "check #{i%3}", fselectbox: "select #{i%3}"
    end

    (4..6).each do |i|
      id = "child_#{i}"
      create :child, id: id, created_by: @field_admin.user_name,
        ftextfield: "#{id} textfield", ftextarea: "#{id} textarea", fnumeric: i.to_s,
        fradiobutton: "radio #{i%3}", fcheckboxes: "check #{i%3}", fselectbox: "select #{i%3}"
    end
  end

  describe 'as field admin' do
    it 'should search textfield' do
      params = { criteria_list: { "0" => { field: 'ftextfield', value: 'textfield' } } }
      f = Forms::SearchForm.new(user: @field_admin, params: params)
      expect(f.execute.results.collect(&:id)).to eq %w(child_1 child_2 child_3 child_4 child_5 child_6)
    end

    it 'should search textarea' do
      params = { criteria_list: { "0" => { field: 'ftextarea', value: 'textarea' } } }
      f = Forms::SearchForm.new(user: @field_admin, params: params)
      expect(f.execute.results.collect(&:id)).to eq %w(child_1 child_2 child_3 child_4 child_5 child_6)
    end

    it 'should search selectbox' do
      params = { criteria_list: { "0" => { field: 'fselectbox', value: 'select 1' } } }
      f = Forms::SearchForm.new(user: @field_admin, params: params)
      expect(f.execute.results.collect(&:id)).to eq %w(child_1 child_4)
    end
  end

end
