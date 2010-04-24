class FormSectionController < ApplicationController
  def index
    @form_sections = FormSection.all.sort{|item1, item2| (item1.order || "0") <=> (item2.order || "0")}
  end
end
 