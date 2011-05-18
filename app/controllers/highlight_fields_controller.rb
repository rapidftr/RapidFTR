class HighlightFieldsController < ApplicationController
  
  def index
    administrators_only
    @forms = FormSection.all
    @highlighted_fields = FormSection.highlighted_fields.map do |field|
      { :field_name => field.name, 
        :display_name => field.display_name, 
        :order => field.highlight_information.order , 
        :form_name => field.form.name 
      }
    end
  end 
  
  def create
    administrators_only
    highlight_fields = params[:fields] 
    highlight_fields.each do|highlight_field|
      FormSection.update_field_as_highlighted highlight_field 
    end
    redirect_to highlight_fields_url
  end

end
