class HighlightFieldsController < ApplicationController
  before_action { authorize! :highlight, Field }

  def index
    @forms = Form.all
  end

  def show
    @page_name = I18n.t("admin.highlight_fields")
    @form = Form.find params[:id]
    @form_sections = @form.sections
    @highlighted_fields = @form.sorted_highlighted_fields.map do |field|
      {:field_name => field.name,
       :display_name => field.display_name,
       :order => field.highlight_information.order,
       :form_name => field.form.name,
       :form_id => field.form.unique_id
      }
    end
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
end
