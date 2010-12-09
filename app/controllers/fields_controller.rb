class FieldsController < ApplicationController

  before_filter :administrators_only

  FIELD_TYPES = %w{ text_field textarea check_box select_box radio_button numeric_field date_field }

  def read_form_section
    @form_section = FormSection.get_by_unique_id(params[:formsection_id])
  end

  def new
    @body_class = 'forms-page'
    read_form_section()
    @suggested_fields = SuggestedField.all_unused
    render params[:fieldtype]
  end

  def create
    @form_section = FormSection.get_by_unique_id(params[:formsection_id])
    properties = params[:field]

    field = Field.new properties
    field.option_strings_text = properties['option_strings_text']
    field.name = field.display_name.dehumanize
    FormSection.add_field_to_formsection @form_section, field
    
    if (field.errors.length == 0)
      SuggestedField.mark_as_used(params[:from_suggested_field]) if params.has_key? :from_suggested_field
      flash[:notice] = "Field successfully added"
      redirect_to(edit_form_section_path(params[:formsection_id]))
    else
      @field = field
      render :action => "new_#{params[:field][:type]}"
    end
  end

  def move_up
    FormSection.get_by_unique_id(params[:formsection_id]).move_up_field(params[:field_name])
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end


  def move_down
    FormSection.get_by_unique_id(params[:formsection_id]).move_down_field(params[:field_name])
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end
  
  def delete
    FormSection.get_by_unique_id(params[:formsection_id]).delete_field(params[:field_name])
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end

  def toggle_fields
    return redirect_to(edit_form_section_path(params[:formsection_id])) if params[:toggle_fields] == 'Cancel' 
    form_section = FormSection.get_by_unique_id(params[:formsection_id])
    if(params[:toggle_fields] == 'Disable')
      form_section.disable_fields(params[:fields])
    else
      form_section.enable_fields(params[:fields])
    end
    form_section.save()
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end

  FIELD_TYPES.each do |field_type|
    define_method "new_#{field_type}" do
      read_form_section()
    end
  end
end
