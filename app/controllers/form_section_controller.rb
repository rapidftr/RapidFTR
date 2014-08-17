class FormSectionController < ApplicationController
  def index
    authorize! :index, FormSection
    @page_name = t("form_section.manage")
    @form_id = params[:form_id]
    @form_sections = FormSection.all.select { |f| f.form_id == @form_id }.sort_by(&:order)
  end

  def create
    authorize! :create, FormSection
    form = Form.find(params[:form_id])
    section_attributes = params[:form_section]
    section_attributes.merge!(:form => form)
    form_section = FormSection.new_with_order section_attributes
    form_section.base_language = I18n.default_locale
    if form_section.valid?
      form_section.create
      flash[:notice] = t("form_section.messages.updated")
      redirect_to edit_form_section_path(form_section.unique_id)
    else
      @form_section = form_section
      @form = form
      render :new
    end
  end

  def edit
    authorize! :update, FormSection
    @page_name = t("form_section.edit")
    @form_section = FormSection.get_by_unique_id(params[:id])
    @form = @form_section.form
  end

  def update
    authorize! :update, FormSection
    @form_section = FormSection.get_by_unique_id(params[:id])
    @form_section.properties = params[:form_section]
    if @form_section.valid?
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

    form = nil
    params[:ids].each_with_index do |unique_id, index|
      form_section = FormSection.get_by_unique_id(unique_id)
      form_section.order = index + 1
      form_section.save!

      form = form_section.form if form.nil?
    end
    redirect_to form_form_sections_path form
  end

  def new
    authorize! :create, FormSection
    @page_name = t("form_section.create")
    @form = Form.find(params[:form_id])
    @form_section = FormSection.new(params[:form_section])
  end

  def destroy
    authorize! :update, FormSection

    @form_section = FormSection.get_by_unique_id(params[:id])
    @form_section.destroy
    form = @form_section.form

    flash[:notice] = t("form_section.messages.deleted", :display_name => @form_section.name)
    redirect_to form_form_sections_path form
  end
end
