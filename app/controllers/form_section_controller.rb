class FormSectionController < ApplicationController

  def index
    authorize! :index, FormSection
    @page_name = t("form_section.manage")
    if params[:form_id]
      @form_sections = Form.find(params[:form_id]).form_sections.sort_by(&:order)
    else
      @form_sections = FormSection.all.sort_by(&:order)
    end
  end

  def create
    authorize! :create, FormSection
    form_section = FormSection.new_with_order params[:form_section]
    form_section.base_language = I18n.default_locale
    if (form_section.valid?)
      form_section.create
      flash[:notice] = t("form_section.messages.updated")
      redirect_to edit_form_section_path(form_section.unique_id)
    else
      @form_section = form_section
      render :new
    end
  end

  def edit
    authorize! :update, FormSection
    @page_name = t("form_section.edit")
    @form_section = FormSection.get_by_unique_id(params[:id])
  end

  def update
    authorize! :update, FormSection
    @form_section = FormSection.get_by_unique_id(params[:id])
    @form_section.properties = params[:form_section]
    if (@form_section.valid?)
      @form_section.save!
      redirect_to edit_form_section_path(@form_section.unique_id)
    else
      render :action => :edit
    end
  end

  def toggle
    authorize! :update, FormSection
    form = FormSection.get_by_unique_id(params[:id])
    form.visible = !form.visible?
    form.save!
    render :text => "OK"
  end


  def save_order
    authorize! :update, FormSection
    params[:ids].each_with_index do |unique_id, index|
      form_section = FormSection.get_by_unique_id(unique_id)
      form_section.order = index + 1
      form_section.save!
    end
    redirect_to form_sections_path
  end

  def new
    authorize! :create, FormSection
    @page_name = t("form_section.create")
    @form_section = FormSection.new(params[:form_section])
  end

end
