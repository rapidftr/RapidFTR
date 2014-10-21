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
      section1 = FormSection.new(:name => 'Section1', :fields => [@title_field])
      section2 = FormSection.new(:name => 'Section2', :fields => [@f1, @f2])
      @form = build :form
      @form.sections = [section1, section2]
    end

    it 'should return currently marked title fields' do
      expect(@form.title_field).to eq(@title_field)
    end

    it 'should unmark all other title fields during an update' do
      @form.update_title_field 'f1', true
      fields = @form.sections.map(&:fields).flatten.reject! { |f| f.name == 'f1' }
      expect(fields.map(&:title_field)).to_not include(true)
    end

    it 'should remove title field if current title field is deselected' do
      @form.update_title_field 'title_field', false
      expect(@form.title_field).to be_nil
      fields = @form.sections.map(&:fields).flatten
      expect(fields.map(&:title_field)).to_not include(true)
    end
  end
end
