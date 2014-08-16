require 'spec_helper'

describe Forms::SearchForm do

  before :all do
    form = create :form, name: Child::FORM_NAME
    create :form_section, form: form, fields: [
      build(:text_field, name: 'ftextfield', highlighted: true),
      build(:text_area_field, name: 'ftextarea', highlighted: true),
      build(:numeric_field, name: 'fnumeric'),
      build(:select_box_field, name: 'fselectbox', option_strings: ['select 1', 'select 2', 'select 3'])
    ]

    @limited_user = create :user, role_ids: [
      create(:role, permissions: [Permission::CHILDREN[:register], Permission::CHILDREN[:edit]]).id
    ]
    @field_worker = create :field_worker_user
  end

  describe 'execute' do
    before(:each) do
      @child_search = ChildSearch.new
      allow(ChildSearch).to receive(:new).and_return(@child_search)
    end

    it 'should not execute search if invalid' do
      f = Forms::SearchForm.new params: {}
      expect(f).not_to receive(:execute_search)
      f.execute
    end

    it 'should execute quick search query' do
      highlighted_fields = ["ftextfield", "ftextarea", :unique_identifier, :short_id]
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { query: 'test query' }
      expect(@child_search).to receive(:fulltext_by).with(highlighted_fields, 'test query')
      f.execute
    end

    it 'should execute created_by_organisation_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { created_by_organisation_value: 'test organisation' }
      expect(@child_search).to receive(:fulltext_by).with([:created_organisation], 'test organisation')
      f.execute
    end

    it 'should execute created_by_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { created_by_value: 'test created by' }
      expect(@child_search).to receive(:fulltext_by).with([:created_by, :created_by_full_name], 'test created by')
      f.execute
    end

    it 'should execute updated_by_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { updated_by_value: 'test updated by' }
      expect(@child_search).to receive(:fulltext_by).with([:last_updated_by, :last_updated_by_full_name], 'test updated by')
      f.execute
    end

    it 'should execute created_at_before_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { created_at_before_value: 'test created before' }
      expect(@child_search).to receive(:less_than).with(:created_at, 'test created before')
      f.execute
    end

    it 'should execute created_at_after_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { created_at_after_value: 'test created after' }
      expect(@child_search).to receive(:greater_than).with(:created_at, 'test created after')
      f.execute
    end

    it 'should execute last_updated_at_before_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { updated_at_before_value: 'test last updated before' }
      expect(@child_search).to receive(:less_than).with(:last_updated_at, 'test last updated before')
      f.execute
    end

    it 'should execute last_updated_at_after_value' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { updated_at_after_value: 'test last updated after' }
      expect(@child_search).to receive(:greater_than).with(:last_updated_at, 'test last updated after')
      f.execute
    end

    it 'should parse dynamic criteria' do
      criteria_list = {
        "0" => { field: "", value: "empty field" },
        "1" => { field: "empty value", value: "" },
        "2" => { field: "ftextfield", value: "search textfield" },
        "3" => { field: "ftextarea", value: "search textarea" }
      }
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { criteria_list: criteria_list }
      expect(@child_search).to receive(:fulltext_by).with(["ftextfield"], 'search textfield')
      expect(@child_search).to receive(:fulltext_by).with(["ftextarea"], 'search textarea')
      f.execute
    end

    it 'should limit search results for field worker' do
      f = Forms::SearchForm.new ability: Ability.new(@limited_user), params: { query: '1234' }
      expect(@child_search).to receive(:created_by).with(@limited_user)
      f.execute
    end

    it 'should not limit search results for field admin' do
      f = Forms::SearchForm.new ability: Ability.new(@field_worker), params: { query: '1234' }
      expect(@child_search).not_to receive(:created_by)
      f.execute
    end

    # TODO: Add pagination specs
  end

end
