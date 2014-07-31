class StandardFormsController < ApplicationController

  def index
    @form_sections = RapidFTR::ChildrenFormSectionSetup.form_sections
  end
end
