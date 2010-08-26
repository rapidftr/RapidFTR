class PublishFormSectionController < ApplicationController

  def form_sections
    enabled_form_sections = FormSection.all_by_order.reject{|fs| !fs.enabled}
    json_content = enabled_form_sections.to_json
    respond_to do |format|
      format.html {render :inline => json_content }
      format.json { render :json => json_content }
    end
  end
end