class FieldsController < ApplicationController

  before_filter :administrators_only
  before_filter :read_form_section
  
  FIELD_TYPES = %w{ text_field textarea check_box select_box radio_button numeric_field date_field }

  def read_form_section
    @form_section = FormSection.get_by_unique_id(params[:formsection_id])
  end

  def new
    @body_class = 'forms-page'
    @suggested_fields = SuggestedField.all_unused
    @field = Field.new(:type => params[:type])
    render params[:fieldtype]
  end
  
  def edit
    @body_class = 'forms-page'
    @field = @form_section.fields.detect {|field| field.name == params[:id] }
  end
  
  def choose
    @body_class = 'forms-page'
    @suggested_fields = SuggestedField.all_unused
  end

  def create
    @field = Field.new params[:field]
    @field.name = @field.display_name.dehumanize 
        
    FormSection.add_field_to_formsection @form_section, @field
        
    if (@field.errors.length == 0)
      SuggestedField.mark_as_used(params[:from_suggested_field]) if params.has_key? :from_suggested_field
      flash[:notice] = "Field successfully added"
      redirect_to(edit_form_section_path(params[:formsection_id]))
    else
      render :action => "new"
    end
  end
  
  def update
    @field = @form_section.fields.detect { |field| field.name == params[:id] }
    @field.attributes = params[:field]
    if params[:destination_form_id] == params[:formsection_id]
      @form_section.save
    else
      @form_section.delete_field @field.name
      destination_form = FormSection.get_by_unique_id(params[:destination_form_id])
      destination_form.add_field @field
      destination_form.save
    end
    
    if (@field.errors.length == 0)
      flash[:notice] = "Field updated"
      redirect_to(edit_form_section_path(params[:formsection_id]))
    else
      render :action => "edit"
    end
  end

  def move_up
    @form_section.move_up_field(params[:field_name])
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end


  def move_down
    @form_section.move_down_field(params[:field_name])
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end
  
  def delete
    field = @form_section.fields.find { |field| field.name == params[:field_name] }
    @form_section.delete_field(field.name)
    flash[:notice] = "Field '#{field.display_name}' has been deleted."
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end

  def toggle_fields
    if params[:fields].nil?
      flash[:error] = "Please select atleast one field to #{params[:toggle_fields]}"
      redirect_to(edit_form_section_path(params[:formsection_id])) and return
    end  

    if(params[:toggle_fields] == 'Disable')
       @form_section.disable_fields(params[:fields])
    else
       @form_section.enable_fields(params[:fields])
    end
     @form_section.save()
    redirect_to(edit_form_section_path(params[:formsection_id]))
  end
end
