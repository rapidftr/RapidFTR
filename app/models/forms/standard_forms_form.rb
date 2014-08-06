module Forms
  class StandardFormsForm
    include ActiveModel::Model
    attr_accessor :forms

    def self.build_from_seed_data
      child_form_sections = RapidFTR::ChildrenFormSectionSetup.build_form_sections
      child_form = StandardFormsData::FormData.build(Form.new(name: Child::FORM_NAME), child_form_sections)

      enquiry_form_sections = RapidFTR::EnquiriesFormSectionSetup.build_form_sections
      enquiry_form = StandardFormsData::FormData.build(Form.new(name: Enquiry::FORM_NAME), enquiry_form_sections)

      form = self.new
      form.forms = [child_form, enquiry_form]
      form
    end
  end

  module StandardFormsData
    class FormData
      include ActiveModel::Model
      attr_accessor :id, :name, :disabled, :sections

      def sections_attributes=(attributes)
        #Need this for the fields_for in the UI
      end

      def self.build form, sections
        id = form.name.downcase
        name = form.name
        existing_form = Form.by_name.key(form.name).first
        disabled = !existing_form.nil?
        data_sections = []
        sections.each do |section|
          data_sections << SectionData.build(section, existing_form)
        end
        self.new id: id, name: name, disabled: disabled, sections: data_sections
      end
    end

    class SectionData
      include ActiveModel::Model
      attr_accessor :id, :name, :fields, :disabled

      def fields_attributes=(attributes)
        #Need this for the fields_for in the UI
      end

      def self.build section, existing_form
        id = section.unique_id
        name = section.name
        existing_section = FormSection.all.all.find {|fs| !existing_form.nil? && fs.form == existing_form && fs.unique_id == section.unique_id}
        disabled = !existing_section.nil?
        data_fields = []
        section.fields.each do |field|
          data_fields << FieldData.build(field, existing_section)
        end
        self.new id: id, name: name, disabled: disabled, fields: data_fields
      end
    end

    class FieldData
      include ActiveModel::Model
      attr_accessor :id, :name, :disabled

      def self.build field, existing_section
        id = field.name
        name = field.display_name
        disabled = existing_section.nil? ? false : existing_section.fields.collect(&:name).include?(field.name)
        self.new id: id, name: name, disabled: disabled
      end
    end
  end
end
