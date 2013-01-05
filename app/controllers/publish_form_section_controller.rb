class PublishFormSectionController < ApplicationController

  def form_sections
    json_content = FormSection.enabled_by_order_without_hidden_fields.to_json
    respond_to do |format|
      format.html {render :inline => json_content }
      format.json { render :json => json_content }
    end
  end
end
