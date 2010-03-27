class FieldsController < ApplicationController
  def index
    
  end

  def new
    field = Field.new()
    render params[:fieldtype]
  end
end
