class FormSectionController < ApplicationController

  before_filter :check_authorization

  def index
    @form_sections = FormSection.all_by_order
  end

  def create
    form_section_vals = params[:form_section]
    result = FormSection.create_new_custom form_section_vals[:name], form_section_vals[:description], form_section_vals[:enabled]=="true"

    if(result.valid?) then
      flash[:notice] = "Form section successfully added"
      redirect_to(formsections_path())
    else  
      @form_section = result
      render :new 
    end
  end
  
  def new
    
  end

  def save
    puts "Saved"
  end

end
