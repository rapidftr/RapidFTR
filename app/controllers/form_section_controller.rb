class FormSectionController < ApplicationController

  before_filter { authorize! :manage, FormSection }

  def index
    @page_name = t("form_section.manage")
    @form_sections = FormSection.all.sort_by(&:order)
  end

  def create
    form_section = FormSection.new_with_order params[:form_section]
    if (form_section.valid?)
      form_section.create!
      flash[:notice] = t("form_section.messages.updated")
      redirect_to(formsections_path())
    else
      @form_section = form_section
      render :new
    end
  end

  def edit
    @page_name = t("form_section.edit")
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


  def save_form_order
    params[:form_order].each do |key, value|
      form_section = FormSection.get_by_unique_id(key)
      form_section.order = value.to_i
      form_section.save!
    end
    redirect_to formsections_url
  end

  def save_field_order
    form_section = FormSection.get_by_unique_id(params[:formId])
    oldFields = Array.new()
    form_section.fields.each do |field|
      oldFields.push field
    end

    params[:form_order].each do |key, value|
      form_section.fields[value.to_i - 1] = oldFields.find{|field| field.name == key}
    end
    form_section.save!
    redirect_to save_field_order_redirect_path
  end

  def save_field_order_redirect_path
    request.env['HTTP_REFERER']
  end

  def new
    @page_name = t("form_section.create")
    @form_section = FormSection.new(params[:form_section])
  end

  def save
    puts t("saved")
  end

end
