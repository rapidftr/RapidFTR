class FormsController < ApplicationController
  def index
    @form_sections = Form.all
  end
end
