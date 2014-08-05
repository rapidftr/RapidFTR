class StandardFormsController < ApplicationController
  def index
    child_form = Form.by_name.key(Child::FORM_NAME).first
    child_form_sections = RapidFTR::ChildrenFormSectionSetup.build_form_sections
    enquiry_form = Form.by_name.key(Enquiry::FORM_NAME).first
    enquiry_form_sections = RapidFTR::EnquiriesFormSectionSetup.build_form_sections

    disable_saved_form_sections child_form, child_form_sections
    disable_saved_form_sections enquiry_form, enquiry_form_sections

    @forms = {
      child: {
        disabled: disable_form?(child_form),
        sections: child_form_sections
      },
      enquiry: {
        disabled: disable_form?(enquiry_form),
        sections: enquiry_form_sections
      }
    }
  end

  def create
    puts params
  end

  private
  def disable_form? form
    !form.nil?
  end

  def disable_saved_form_sections saved_form, sections
    if !saved_form.nil?
      saved_sections = FormSection.all.all.select {|fs| fs.form == saved_form}
      saved_section_names = saved_sections.collect(&:name)
      sections.each do |section|
        section[:disabled] = saved_section_names.include?(section.name)
      end
    end
  end
end
