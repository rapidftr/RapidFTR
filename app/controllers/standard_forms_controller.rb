class StandardFormsController < ApplicationController
  def index
    @forms = {
      child: RapidFTR::ChildrenFormSectionSetup.build_form_sections,
      enquiry: RapidFTR::EnquiriesFormSectionSetup.build_form_sections
    }
  end
end
