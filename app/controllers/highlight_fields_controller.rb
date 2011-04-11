class HighlightFieldsController < ApplicationController
  def edit
    administrators_only
    @forms = FormSection.all
  end 

end
