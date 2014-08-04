class Api::FormSectionsController < Api::ApiController

  def index
    forms_json = {}
    form_sections = FormSection.enabled_by_order_without_hidden_fields
    form_sections.each do |section|
      form_name = section.form.name
      forms_json[form_name] = forms_json[form_name].nil? ? [] : forms_json[form_name]
      forms_json[form_name] << section.formatted_hash
    end
    render json: forms_json
  end

  def children
    form_sections = FormSection.enabled_by_order_for_form(Child::FORM_NAME)
    render json: form_sections.map(&:formatted_hash)
  end
end

