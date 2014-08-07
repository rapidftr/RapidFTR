class FormsController < ApplicationController
  def index
    @form_sections = Form.all
  end

  def bulk_update
    require 'pry'
    binding.pry
    if !params[:enquiry_form_sections].nil?
      form = Form.find_or_create_by_name Enquiry::FORM_NAME
      create_form_sections(form, params[:enquiry_form_sections], RapidFTR::EnquiriesFormSectionSetup.build_form_sections, params)
    end
    if !params[:child_form_sections].nil?
      form = Form.find_or_create_by_name Child::FORM_NAME
      create_form_sections(form, params[:child_form_sections], RapidFTR::ChildrenFormSectionSetup.build_form_sections, params)
    end
  end

  private
  def create_form_sections form, selected_form_section_names, standard_form_sections, params
    sections_to_save = standard_form_sections.select {|fs| selected_form_section_names.include?(fs.unique_id)}
    sections_to_save.each do |section|
      selected_fields = section.fields.select{|field| params[section.unique_id].include? field.name }
      section.form = form
      if section.send(:validate_unique_name) != true #Returns true or an array, so don't rely on truthy values
        section = FormSection.all.find {|fs| fs.name == section.name && fs.form == section.form}
        section.merge_fields selected_fields
      else
        section.fields = selected_fields
      end
      section.save
    end
  end
end

