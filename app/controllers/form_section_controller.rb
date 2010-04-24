class FormSectionController < ApplicationController
  def index
    @form_sections = FormSection.all.sort{|item1, item2| (item1.order || "0") <=> (item2.order || "0")}
  end

  def create
    unique_id = params[:form_section][:name].gsub(/\s/, "_").downcase
    order_number = params[:form_section][:order].to_i
    new_form_section = FormSection.new(params[:form_section])
    new_form_section.order = order_number 
    new_form_section.unique_id = unique_id
    new_form_section.save
    flash[:notice] = "Form successfully added"
    redirect_to(formsections_path())
  end
  
  def new
    
  end

  def save
    puts "Saved"
  end

end
