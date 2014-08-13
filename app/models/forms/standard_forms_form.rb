module Forms
  class StandardFormsForm
    include ActiveModel::Model
    attr_accessor :forms

    def self.build_from_seed_data
      child_form_sections = RapidFTR::ChildrenFormSectionSetup.build_form_sections
      child_form = StandardFormsData::FormData.build(Form.new(:name => Child::FORM_NAME), child_form_sections)

      form_sections = RapidFTR::EnquiriesFormSectionSetup.build_form_sections
      enquiry_form = StandardFormsData::FormData.build(Form.new(:name => Enquiry::FORM_NAME), form_sections)

      form = new
      form.forms = [child_form, enquiry_form]
      form
    end
  end

  module StandardFormsData
    class FormData
      include ActiveModel::Model
      attr_accessor :id, :name, :disabled, :sections, :user_selected

      def user_selected
        @user_selected ||= false
      end

      def self.build(form, sections)
        id = form.name.downcase
        name = form.name
        existing_form = Form.by_name.key(form.name).first
        disabled = !existing_form.nil?
        data_sections = []
        sections.each do |section|
          data_sections << SectionData.build(section, existing_form)
        end
        new :id => id, :name => name, :disabled => disabled, :sections => data_sections
      end
    end

    class SectionData
      include ActiveModel::Model
      attr_accessor :id, :name, :fields, :disabled, :user_selected

      def user_selected
        @user_selected ||= false
      end

      def self.build(section, existing_form)
        id = section.name
        name = section.name
        existing_section = FormSection.all.all.find { |fs| !existing_form.nil? && fs.form == existing_form && fs.name == section.name }
        disabled = !existing_section.nil?
        data_fields = []
        section.fields.each do |field|
          data_fields << FieldData.build(field, existing_section)
        end
        new :id => id, :name => name, :disabled => disabled, :fields => data_fields
      end
    end

    class FieldData
      include ActiveModel::Model
      attr_accessor :id, :name, :disabled, :user_selected

      def user_selected
        @user_selected ||= false
      end

      def self.build(field, existing_section)
        id = field.name
        name = field.display_name
        disabled = existing_section.nil? ? false : existing_section.fields.map(&:name).include?(field.name)
        new :id => id, :name => name, :disabled => disabled
      end
    end
  end
end
