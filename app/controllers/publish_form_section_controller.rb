class PublishFormSectionController < ApplicationController

  def form_sections
    enabled_form_sections = FormSection.all_by_order.reject{|fs| !fs.enabled}
    render :inline => enabled_form_sections.to_json
  end
end