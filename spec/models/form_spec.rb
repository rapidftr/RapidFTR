# -*- coding: utf-8 -*-
require 'spec_helper'

describe Form, :type => :model do
  describe 'highlighted_fields' do

    before :each do
      high_attr = [{:order => '1', :highlighted => true}, {:order => '2', :highlighted => true}, {:order => '10', :highlighted => true}]
      @highlighted_fields = [Field.new(:name => 'h1', :highlighted => true, :highlight_information => high_attr[0]),
                             Field.new(:name => 'h2', :highlighted => true, :highlight_information => high_attr[1]),
                             Field.new(:name => 'h3', :highlighted => true, :highlight_information => high_attr[2])]
      field = Field.new :name => 'regular_field'
      form_section1 = FormSection.new(:name => 'Highlight Form1', :fields => [@highlighted_fields[0], @highlighted_fields[2], field])
      form_section2 = FormSection.new(:name => 'Highlight Form2', :fields => [@highlighted_fields[1]])
      @form = build :form
      @form.sections = [form_section1, form_section2]
    end

    it 'should get fields that have highlight information' do
      highlighted_fields = @form.highlighted_fields
      expect(highlighted_fields.size).to eq(@highlighted_fields.size)
      expect(highlighted_fields.map { |field| field.highlight_information }).
        to match_array(@highlighted_fields.map { |field| field.highlight_information })
    end

    it 'should sort the highlighted fields by highlight order' do
      sorted_highlighted_fields = @form.sorted_highlighted_fields

      expect(sorted_highlighted_fields.map { |field| field.highlight_information.order }).to eq(
        @highlighted_fields.map { |field| field.highlight_information.order }
      )
    end
  end

  describe 'update_title_field' do
    before :each do
      @title_field = build :field, :name => 'title_field', :title_field => true, :highlighted => true
      @f1 = build :field, :name => 'f1', :highlighted => true
      @f2 = build :field, :name => 'f2', :highlighted => true
      @section1 = FormSection.new(:name => 'Section1', :fields => [@title_field])
      @section2 = FormSection.new(:name => 'Section2', :fields => [@f1, @f2])
      @form = build :form
      @form.sections = [@section1, @section2]
    end

    it 'should return currently marked title fielids' do
      expect(@form.title_fields.length).to eq(1)
      expect(@form.title_fields.first).to eq(@title_field)
    end

    it 'should not unmark all other title fields during an update' do
      @form.update_title_field 'f1', true
      title_fields = @form.title_fields
      expect(title_fields.length).to eq(2)
      expect(title_fields[0].name).to eq('title_field')
      expect(title_fields[1].name).to eq('f1')
    end

    it 'should remove title field if current title field is deselected' do
      @form.update_title_field 'title_field', false
      expect(@form.title_fields).to be_empty
    end

    it 'should save sections without callbacks' do
      expect(@section1).to receive(:without_update_hooks)
      expect(@section2).to receive(:without_update_hooks)
      @form.update_title_field 'title_field', false
    end
  end

  describe 'removing a form' do
    before :each do

      FormSection.all.all.each { |fs| fs.destroy }
      Form.all.all.each { |f| f.destroy }

      @title_field = build :field, :name => 'title_field', :title_field => true, :highlighted => true
      @f1 = build :field, :name => 'f1', :highlighted => true
      @f2 = build :field, :name => 'f2', :highlighted => true

      @form = build :form
      @form.save!
      @section1 = FormSection.create(:name => 'Section1', :fields => [@title_field], :form_id => @form.id)
      @section2 = FormSection.create(:name => 'Section2', :fields => [@f1, @f2], :form_id => @form.id)
    end

    it 'should remove form sections for a form when the form is removed removed' do
      sections = FormSection.all.all.select { |fs| fs.form == @form }
      expect(sections.count).to eq(2)

      @form.destroy
      expect(FormSection.all.count).to eq(0)

      sections = FormSection.all.all.select { |fs| fs.form == @form }
      expect(sections.count).to eq(0)
    end
  end
end
