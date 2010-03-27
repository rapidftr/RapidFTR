class FormSectionController < ApplicationController
  def index
#    @thing = FormSection.new
#    @thing.add_field(Field.new("sme name", "_text_field"))

    @form_sections = FormSectionRepository.all

  end
end
