class FieldsController < ApplicationController
  before_action { authorize! :manage, Field }
  before_action :read_form_section
  before_action :set_form

  FIELD_TYPES = %w(text_field textarea check_box select_box radio_button numeric_field date_field)

  def read_form_section
    @form_section = FormSection.get_by_unique_id(params[:form_section_id])
  end

  def set_form
    @form = @form_section.form
  end

  def create
    @field = Field.new params[:field]
    FormSection.add_field_to_formsection @form_section, @field
    @field.base_language = I18n.default_locale
    if (@field.errors.length == 0)
      flash[:notice] = t("fields.successfully_added")
      redirect_to(edit_form_section_path(params[:form_section_id]))
    else
      @show_add_field = {:show_add_field => true}
      render :template => "form_section/edit", :locals => @show_add_field
    end
  end

  def edit
    @body_class = 'forms-page'
    @field = @form_section.fields.find { |field| field.name == params[:id] }
    @show_add_field = {:show_add_field => true}
    render :template => "form_section/edit", :locals => @show_add_field
  end

  def change_form
    @field = @form_section.fields.find { |field| field.name == params[:id] }
    @form_section.delete_field @field.name
    destination_form = FormSection.get_by_unique_id(params[:destination_form_id])
    destination_form.add_field @field
    destination_form.save
    flash[:notice] = t("moved_from", :field_name => @field.display_name, :from_fs => @form_section.name, :to_fs => destination_form.name)
    redirect_to edit_form_section_path(params[:form_section_id])
  end

  def update
    @field = fetch_field params[:id]
    @field.attributes = params[:field] unless params[:field].nil?
    @form_section.save
    @show_add_field = {:show_add_field => true}
    if (@field.errors.length == 0)
      flash[:notice] = t("fields.updated")
      message = {"status" => "ok"}
      if request.xhr?
        render :json => message
      else
        render :template => "form_section/edit", :locals => @show_add_field
      end
    else
      render :template => "form_section/edit",  :locals => @show_add_field
    end
  end

  def save_order
    @form_section.order_fields(params[:ids])
    redirect_to(edit_form_section_path(params[:form_section_id]))
  end

  def show
    redirect_to(edit_form_section_path(params[:form_section_id]))
  end

  def destroy
    field = @form_section.fields.find { |f| f.name == params[:field_name] }
    @form_section.delete_field(field.name)
    flash[:notice] = t("fields.deleted", :display_name => field.display_name)
    redirect_to(edit_form_section_path(params[:form_section_id]))
  end

  def toggle_fields
    field =  fetch_field params[:id]
    field.visible = !field.visible
    @form_section.save
    render :text => "OK"
  end

  private

  def fetch_field(field_name)
    @form_section.fields.find { |field| field.name == field_name }
  end
end
