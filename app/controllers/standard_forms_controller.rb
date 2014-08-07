class StandardFormsController < ApplicationController
  def index
    @default_forms = Forms::StandardFormsForm.build_from_seed_data
  end
end
