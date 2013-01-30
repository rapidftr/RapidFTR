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
      redirect_to edit_form_section_path(form_section.unique_id)
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
      redirect_to edit_form_section_path(@form_section.unique_id)
    else
      render :action => :edit
    end
  end

  def enable
    forms = params[:sections]
    if forms
      forms.each_key do |key|
        form = FormSection.get_by_unique_id(key)
        form.visible = params[:value]
        form.save!
      end
    end
    render :text => "OK"
  end


  def save_form_order
    params[:ids].each_with_index do |unique_id, index|
      form_section = FormSection.get_by_unique_id(unique_id)
      form_section.order = index + 1
      form_section.save!
    end
    redirect_to form_section_index_path
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
