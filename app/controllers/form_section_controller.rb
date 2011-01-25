class FormSectionController < ApplicationController

  before_filter :administrators_only

  def index
    @form_sections = FormSection.all.sort_by { |row| [row.enabled ? 0 : 1, row.order] }
  end

  def create
    form_section_vals = params[:form_section]
    result = FormSection.create_new_custom form_section_vals[:name], form_section_vals[:description], form_section_vals[:enabled]=="true"

    if (result.valid?) then
      flash[:notice] = "Form section successfully added"
      redirect_to(formsections_path())
    else
      @form_section = result
      render :new
    end
  end
  
  def edit
    @form_section = FormSection.get_by_unique_id(params[:id])
  end
  
  def update
    @form_section = FormSection.get_by_unique_id(params[:id])
    @form_section.properties = params[:form_section]
    if (@form_section.valid?)
      @form_section.save!
      redirect_to formsections_path
    else
      render :action => :edit
    end
  end

  def enable
    forms = params[:sections]
    if forms
      forms.each_key do |key|
        form = FormSection.get_by_unique_id(key)
        form.enabled = params[:value]
        form.save!
      end
    end
    redirect_to formsections_url
  end
  
  def save_order
    params[:form_order].each do |key, value|
      form_section = FormSection.get_by_unique_id(key)
      form_section.order = value.to_i
      form_section.save!
    end
    redirect_to formsections_url
  end
  
  def new
    @form_section = FormSection.new(params[:form_section])
  end

  def save
    puts "Saved"
  end

end
