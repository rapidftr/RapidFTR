class FieldsController < ApplicationController
  FIELD_TYPES = %w{text_field textarea check_box select_drop_down}
  def index 
    @form_section = FormSectionDefinition.get_by_unique_id(params[:formsection_id])
  end

  def new
    render params[:fieldtype]
  end

  FIELD_TYPES.each do |field_type|
    define_method "new_#{field_type}" do
    end
  end
end
