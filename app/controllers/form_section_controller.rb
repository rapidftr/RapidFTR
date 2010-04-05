class FormSectionController < ApplicationController
  def index
#    @thing = FormSection.new
#    @thing.add_field(Field.new("sme name", "_text_field"))

    @form_sections = FormSectionDefinition.all.sort{|item1, item2| (item1.order || "0") <=> (item2.order || "0")}

  end
end
 