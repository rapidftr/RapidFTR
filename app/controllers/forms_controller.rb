class FormsController < ApplicationController
  def index
    @forms = Form.all

  end
end