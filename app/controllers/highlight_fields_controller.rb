class HighlightFieldsController < ApplicationController

  before_filter { authorize! :highlight, Field }

  def index
    @forms = Form.all
  end

  def show
    @page_name = I18n.t("admin.highlight_fields")
    form = Form.find params[:id]
    @form_sections = form.sections
    @highlighted_fields = form.sorted_highlighted_fields.map do |field|
      { :field_name => field.name,
        :display_name => field.display_name,
        :order => field.highlight_information.order ,
        :form_name => field.form.name,
        :form_id => field.form.unique_id
      }
    end
  end

  def create
    form = FormSection.get_by_unique_id(params[:form_id])
    form.update_field_as_highlighted params[:field_name]
    redirect_to highlight_fields_url
  end

  def remove
    form = FormSection.get_by_unique_id(params[:form_id])
    form.remove_field_as_highlighted params[:field_name]
    redirect_to highlight_fields_url
  end
end
