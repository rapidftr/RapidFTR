class HighlightFieldsController < ApplicationController
  
  def index
    administrators_only
    @forms = FormSection.all
    @highlighted_fields = FormSection.sorted_highlighted_fields.map do |field|
      { :field_name => field.name, 
        :display_name => field.display_name, 
        :order => field.highlight_information.order , 
        :form_name => field.form.name,
        :form_id => field.form.unique_id 
      }
    end
  end 
  
  def create
    administrators_only
    form = FormSection.get_by_unique_id(params[:form_id])
    form.update_field_as_highlighted params[:field_name]
    redirect_to highlight_fields_url
  end

end
