class StandardFormsController < ApplicationController
  def index
    @default_forms = Forms::StandardFormsForm.build_from_seed_data
    @new_form = Forms::StandardFormsForm.new
  end
end
