class HighlightFieldsController < ApplicationController
  before_action { authorize! :highlight, Field }

  def index
    @forms = Form.all
  end

  def show
    @page_name = I18n.t('admin.highlight_fields')
    @form = Form.find params[:id]
    @form_sections = @form.sections
    @highlighted_fields = @form.sorted_highlighted_fields
  end

  def create
    form_section = FormSection.get_by_unique_id(params[:form_id])
    form_section.update_field_as_highlighted params[:field_name]
    redirect_to highlight_field_url(form_section.form)
  end

  def remove
    form_section = FormSection.get_by_unique_id(params[:form_id])
    form_section.remove_field_as_highlighted params[:field_name]
    redirect_to highlight_field_url(form_section.form)
  end

  def update_title_field
    form = FormSection.get_by_unique_id(params[:form_id]).form
    new_value = params[:value] == 'true'
    form.update_title_field params[:field_name], new_value
    render :json => {}
  end
end
