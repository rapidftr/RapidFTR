# -*- coding: utf-8 -*-
require 'spec_helper'

describe FormSection, :type => :model do

  def create_formsection(stubs={})
    stubs.reverse_merge!(:fields=>[], :save => true, :editable => true, :base_language => "en")
    @create_formsection = FormSection.new stubs
  end

  def new_should_be_called_with (name, value)
    expect(FormSection).to receive(:new) { |form_section_hash|
      expect(form_section_hash[name]).to eq(value)
    }
  end

  it "should return all the searchable fields" do
    text_field = Field.new(:name => "text_field", :type => Field::TEXT_FIELD)
    text_area = Field.new(:name => "text_area", :type => Field::TEXT_AREA)
    select_box = Field.new(:name => "select_box", :type => Field::SELECT_BOX)
    radio_button = Field.new(:name => "radio_button", :type => Field::RADIO_BUTTON)
    f = FormSection.new(:fields => [text_field, text_area, select_box, radio_button])
    expect(f.all_searchable_fields).to eq([text_field, text_area, select_box])
  end

  it "udpates solr child index when created" do
    form = FormSection.new()
    expect(Child).to receive(:update_solr_indices)
    form.run_callbacks(:create)
  end
  
  it "updates solr child index when updated" do
    form = FormSection.new()
    expect(Child).to receive(:update_solr_indices)
    form.run_callbacks(:update)
  end
  
  describe '#unique_id' do
    it "should be generated when not provided" do
      f = FormSection.new
      expect(f.unique_id).not_to be_empty
    end

    it "should not be generated when provided" do
      f = FormSection.new :unique_id => 'test_form'
      expect(f.unique_id).to eq('test_form')
    end

    it "should not allow duplicate unique ids" do
      FormSection.new(:unique_id => "test", :name => "test").save!

      expect {
        FormSection.new(:unique_id => "test").save!
      }.to raise_error

      expect {
        FormSection.get_by_unique_id("test").save!
      }.to_not raise_error
    end
  end

  describe "repository methods" do
    before { FormSection.all.each &:destroy }

    describe "enabled_by_order" do
      it "should bring back sections in order" do
        second = FormSection.create! :name => 'Second', :order => 2, :unique_id => 'second'
        first = FormSection.create! :name => 'First', :order => 1, :unique_id => 'first'
        third = FormSection.create! :name => 'Third', :order => 3, :unique_id => 'third'
        expect(FormSection.enabled_by_order.map(&:name)).to eq(%w( First Second Third ))
      end

      it "should exclude disabled sections" do
        expected = FormSection.create! :name => 'Good', :order => 1, :unique_id => 'good'
        unwanted = FormSection.create! :name => 'Bad', :order => 2, :unique_id => 'bad', :visible => false
        expect(FormSection.enabled_by_order.map(&:name)).to eq(%w(Good))
        expect(FormSection.enabled_by_order.map(&:name)).not_to eq(%w(Bad))
      end
    end

    describe "enabled_by_order_without_hidden_fields" do
      it "should exclude hidden fields" do
        visible_field = Field.new(:name => "visible_field", :display_name => "Visible Field", :visible => true)
        hidden_field = Field.new(:name => "hidden_field", :display_name => "Hidden Field", :visible => false)

        section = FormSection.new :name => 'section', :order => 1, :unique_id => 'section'
        section.fields = [visible_field, hidden_field]
        section.save!

        form_section = FormSection.enabled_by_order_without_hidden_fields.first
        expect(form_section.fields).to eq([visible_field])
      end
    end
  end

  describe "get_by_unique_id" do
    it "should retrieve formsection by unique id" do
      expected = FormSection.new
      unique_id = "fred"
      allow(FormSection).to receive(:by_unique_id).with(:key=>unique_id).and_return([expected])
      expect(FormSection.get_by_unique_id(unique_id)).to eq(expected)
    end

    it "should save fields" do
      section = FormSection.new :name => 'somename', :unique_id => "someform"
      section.save!

      section.fields = [Field.new(:name => "a_field", :type => "text_field", :display_name => "A Field")]
      section.save!

      field = section.fields.first
      field.name = "kev"
      section.save!

      section = FormSection.get_by_unique_id("someform")
      expect(section.name).to eq('somename')
    end

  end

  describe "add_field_to_formsection" do

    it "adds the field to the formsection" do
      field = build(:text_field)
      formsection = create_formsection :fields => [build(:field), build(:field)], :save => true
      FormSection.add_field_to_formsection formsection, field
      expect(formsection.fields.length).to eq(3)
      expect(formsection.fields[2]).to eq(field)
    end

    it "adds base_language to fields in formsection" do
      field = build :text_area_field, name: "name"
      formsection = create_formsection :fields => [build(:field), build(:field)], :save=>true
      FormSection.add_field_to_formsection formsection, field
      expect(formsection.fields[2]).to have_key("base_language")
    end

    it "saves the formsection" do
      field = build(:text_field)
      formsection = create_formsection
      expect(formsection).to receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

    it "should raise an error if adding a field to a non editable form section" do
      field = build :field
      formsection = FormSection.new :editable => false
      expect { FormSection.add_field_to_formsection formsection, field }.to raise_error
    end

  end

  describe "add_textarea_field_to_formsection" do

    it "adds the textarea to the formsection" do
      field = build :text_area_field, name: "name"
      formsection = create_formsection :fields => [build(:field), build(:field)], :save=>true
      FormSection.add_field_to_formsection formsection, field
      expect(formsection.fields.length).to eq(3)
      expect(formsection.fields[2]).to eq(field)
    end

    it "saves the formsection with textarea field" do
      field = build :text_area_field, name: "name"
      formsection = create_formsection
      expect(formsection).to receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "add_select_drop_down_field_to_formsection" do

    it "adds the select drop down to the formsection" do
      field = build(:select_box_field)
      formsection = create_formsection :fields => [build(:field), build(:field)], :save=>true
      FormSection.add_field_to_formsection formsection, field
      expect(formsection.fields.length).to eq(3)
      expect(formsection.fields[2]).to eq(field)
    end

    it "saves the formsection with select drop down field" do
      field = build(:select_box_field)
      formsection = create_formsection
      expect(formsection).to receive(:save)
      FormSection.add_field_to_formsection formsection, field
    end

  end

  describe "editable" do

    it "should be editable by default" do
      formsection = FormSection.new
      expect(formsection.editable?).to be_truthy
    end

  end

  describe "perm_visible" do
    it "should not be perm_enabled by default" do
      formsection = FormSection.new
      expect(formsection.perm_visible?).to be_falsey
    end

    it "should be perm_visible when set" do
      formsection = FormSection.new(:perm_visible => true)
      expect(formsection.perm_visible?).to be_truthy
    end
  end

  describe "fixed_order" do
    it "should not be fixed)order by default" do
      formsection = FormSection.new
      expect(formsection.fixed_order?).to be_falsey
    end

    it "should be fixed_order when set" do
      formsection = FormSection.new(:fixed_order => true)
      expect(formsection.fixed_order?).to be_truthy
    end
  end

  describe "perm_enabled" do
    it "should not be perm_enabled by default" do
      formsection = FormSection.new
      expect(formsection.perm_enabled?).to be_falsey
    end

    it "should be perm_enabled when set" do
      formsection = FormSection.create!(:name => "test", :uniq_id => "test_id", :perm_enabled => true)
      expect(formsection.perm_enabled?).to be_truthy
      expect(formsection.perm_visible?).to be_truthy
      expect(formsection.fixed_order?).to be_truthy
      expect(formsection.visible?).to be_truthy
    end
  end

  describe "delete_field" do
    it "should delete editable fields" do
      @field = build :field
      form_section = FormSection.new :fields=>[@field]
      form_section.delete_field(@field.name)
      expect(form_section.fields).to be_empty
    end

    it "should not delete uneditable fields" do
      @field = build(:field, editable: false)
      form_section = FormSection.new :fields=>[@field]
      expect {form_section.delete_field(@field.name)}.to raise_error("Uneditable field cannot be deleted")
    end
  end

  describe "save fields in given order" do
    it "should save the fields in the given field name order" do
      @field_1 = build :field, name: 'orderfield1'
      @field_2 = build :field, name: 'orderfield2'
      @field_3 = build :field, name: 'orderfield3'
      form_section = FormSection.create! :name => "some_name", :fields => [@field_1, @field_2, @field_3]
      form_section.order_fields([@field_2.name, @field_3.name, @field_1.name])
      expect(form_section.fields).to eq([@field_2, @field_3, @field_1])
      expect(form_section.fields.first).to eq(@field_2)
      expect(form_section.fields.last).to eq(@field_1)
    end
  end

  describe "new_with_order" do
    before :each do
      allow(FormSection).to receive(:all).and_return([])
    end
    it "should create a new form section" do
      expect(FormSection).to receive(:new).at_least(:once)
      FormSection.new_with_order({:name => "basic"})
    end

    it "should set the order to one plus maximum order value" do
      allow(FormSection).to receive(:by_order).and_return([FormSection.new(:order=>20), FormSection.new(:order=>10), FormSection.new(:order=>40)])
      new_should_be_called_with :order, 41
      FormSection.new_with_order({:name => "basic"})
    end
  end

  describe "valid?" do
    before { FormSection.all.each &:destroy }
    it "should validate name is filled in" do
      form_section = FormSection.new()
      expect(form_section).not_to be_valid
      expect(form_section.errors["name_#{I18n.default_locale}"]).to be_present
    end

    it "should not allows empty form names in form base_language " do
      form_section = FormSection.new(:name_en => 'English', :name_zh=>'Chinese')
      I18n.default_locale='zh'
      expect {
        form_section[:name_en]=''
        form_section.save!
      }.to raise_error
    end

    it "should validate name is alpha_num" do
      form_section = FormSection.new(:name=> "r@ndom name!")
      expect(form_section).not_to be_valid
      expect(form_section.errors[:name]).to be_present
    end

    it "should not allow name with white spaces only" do
      form_section = FormSection.new(:name=> "     ")
      expect(form_section).not_to be_valid
      expect(form_section.errors[:name]).to be_present
    end

    it "should allow arabic names" do
      form_section = FormSection.new(:name=>"العربية")
      expect(form_section).to be_valid
      expect(form_section.errors[:name]).not_to be_present
    end

    it "should validate name is unique" do
      same_name = 'Same Name'
      valid_attributes = {:name => same_name, :unique_id => same_name.dehumanize, :description => '', :visible => true, :order => 0}
      FormSection.create! valid_attributes.dup
      form_section = FormSection.new valid_attributes.dup
      expect(form_section).not_to be_valid
      expect(form_section.errors[:name]).to be_present
      expect(form_section.errors[:unique_id]).to be_present
    end

    it "should validate name is unique only within parent form" do
      same_name = 'Same Name'
      form = build :form
      other_form = build :form
      valid_attributes = {:name => same_name, :unique_id => same_name.dehumanize, :description => '', :visible => true, :order => 0, :form => form}
      FormSection.create! valid_attributes.dup

      valid_attributes[:form] = other_form
      valid_attributes[:unique_id] = "some_other_id"
      form_section = FormSection.new valid_attributes
      expect(form_section).to be_valid
    end

    it "should not occur error  about the name is not unique  when the name is not filled in" do
      form_section = FormSection.new(:name=>"")
      expect(form_section).not_to be_valid
      expect(form_section.errors[:unique_id]).not_to be_present
    end

    it "should not trip the unique name validation on self" do
      form_section = FormSection.new(:name => 'Unique Name', :unique_id => 'unique_name')
      form_section.create!
    end
  end

  describe "highlighted_fields" do
    it "should update field as highlighted" do
      attrs = { :field_name => "h1", :form_id => "highlight_form" }
      existing_field = Field.new :name => attrs[:field_name]
      form = build :form
      form_section = FormSection.new(:name => "Some Form",
                                     :unique_id => attrs[:form_id],
                                     :fields => [existing_field],
                                     :form => form)
      allow(form).to receive(:highlighted_fields).and_return([])
      allow(FormSection).to receive(:all).and_return([form_section])
      form_section.update_field_as_highlighted attrs[:field_name]
      expect(existing_field.highlight_information.order).to eq(1)
      expect(existing_field.is_highlighted?).to be_truthy
    end

    it "should increment order of the field to be highlighted" do
      attrs = { :field_name => "existing_field", :form_id => "highlight_form"}
      existing_field = Field.new :name => attrs[:field_name]
      existing_highlighted_field = Field.new :name => "highlighted_field"
      existing_highlighted_field.highlight_with_order 3
      form = build :form
      form_section = FormSection.new(:name => "Some Form",
                                     :unique_id => attrs[:form_id],
                                     :fields => [existing_field, existing_highlighted_field],
                                     :form => form)
      allow(form).to receive(:highlighted_fields).and_return([existing_highlighted_field])
      allow(FormSection).to receive(:all).and_return([form_section])
      form_section.update_field_as_highlighted attrs[:field_name]
      expect(existing_field.is_highlighted?).to be_truthy
      expect(existing_field.highlight_information.order).to eq(4)
    end

    it "should un-highlight a field" do
      existing_highlighted_field = Field.new :name => "highlighted_field"
      existing_highlighted_field.highlight_with_order 1
      form = FormSection.new(:name => "Some Form", :unique_id => "form_id",
                             :fields => [existing_highlighted_field])
      allow(FormSection).to receive(:all).and_return([form])
      form.remove_field_as_highlighted existing_highlighted_field.name
      expect(existing_highlighted_field.is_highlighted?).to be_falsey
    end

    describe "formatted hash" do
      it "should combine the translations into a hash" do
        fs = FormSection.new(:name_en => "english name", :name_fr => "french name", :unique_id => "unique id",
                             :fields => [Field.new(:display_name_en => "dn in english", :display_name_zh => "dn in chinese", :name => "name")])
        form_section = fs.formatted_hash
        expect(form_section["name"]).to eq({"en" => "english name", "fr" => "french name"})
        expect(form_section["unique_id"]).to eq("unique id")
        expect(form_section["fields"].first["display_name"]).to eq({"en" => "dn in english", "zh" => "dn in chinese"})
        expect(form_section["fields"].first["name"]).to eq("name")
      end
    end
  end

  describe "#field_by_id" do

    it 'should find field by id' do
      expected_field = Field.new(:name => "a_field", :type => "text_field", :display_name => "A Field")
      form_section = FormSection.new :name => 'form_section', :unique_id => "unique_id", :fields => [expected_field]
      form_section.save!

      retrieved_field = form_section.get_field_by_name("a_field")
      expect(expected_field).to eq(retrieved_field)
    end

    it 'should return nothing when field name does not match' do
      form_section = FormSection.new :name => 'new_form_section', :unique_id => "new_unique_id"
      form_section.save!

      expected_field = form_section.get_field_by_name("some_other_field")
      expect(expected_field).to eq(nil)
    end
  end

  describe ".all_sortable_field_names" do
    before :each do
      reset_couchdb!
    end

    it "should return searchable fields" do
      text_field = build :text_field, :name => "text_field", :display_name => "Text Field"
      text_area = build :text_area_field, :name => "text_area", :display_name => "Text Area"
      select_box = build :select_box_field, :name => "select_box", :display_name => "Select Box"
      numeric_field = build :numeric_field, :name => "numeric_field", :display_name => "Numeric Field"
      form_section = create :form_section, :name => 'sortable_form_section', :unique_id => "unique_id", :fields => [text_field, text_area, select_box, numeric_field]

      expect(FormSection.all_sortable_field_names).to eq(["text_field","text_area","select_box"])
    end

    it "should not return hidden fields" do
      text_field = Field.new(:name => "visible_text_field", :type => "text_field", :display_name => "Visible Text Field")
      hidden_text_field = Field.new(:name => "hidden_text_field", :type => "text_field", :display_name => "Hidden Text Field", :visible => false)
      form_section = FormSection.create :name => 'form_section', :unique_id => "unique_id", :fields => [text_field, hidden_text_field]

      expect(FormSection.all_sortable_field_names).to eq(["visible_text_field"])
    end
  end

  describe "#enabled_by_order_for_form" do
    after :each do
      FormSection.all.each &:destroy
      Form.all.each &:destroy
    end

    it "should only return visible form sections" do
      form = create :form, name: "Form Name"
      section1 = create :form_section, form: form
      section2 = create :form_section, form: form, visible: false

      expect(FormSection.enabled_by_order_for_form("Form Name")).to eq([section1])
    end

    it "should only return form sections for the form" do
      form = create :form, name: "Form Name"
      other_form = create :form, name: "Other Name"
      section1 = create :form_section, form: form
      section2 = create :form_section, form: other_form

      expect(FormSection.enabled_by_order_for_form("Form Name")).to eq([section1])
    end

    it "should only order form sections" do
      form = create :form, name: "Form Name"
      section1 = create :form_section, form: form, order: 2
      section2 = create :form_section, form: form, order: 1

      expect(FormSection.enabled_by_order_for_form("Form Name")).to eq([section2, section1])
    end
  end
end
