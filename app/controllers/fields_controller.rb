class FieldsController < ApplicationController
  FIELD_TYPES = %w{text_field textarea check_box select_drop_down}

  def read_form_section
    @form_section = FormSectionDefinition.get_by_unique_id(params[:formsection_id])
  end

  def index
    read_form_section()
  end

  def new
    read_form_section()
    @suggested_fields = SuggestedField.all
    render params[:fieldtype]
  end

  FIELD_TYPES.each do |field_type|
    define_method "new_#{field_type}" do
    end
  end
end
