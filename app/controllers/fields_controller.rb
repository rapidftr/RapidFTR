class FieldsController < ApplicationController
  def index
    
  end

  def new
    render params[:fieldtype]
  end
end
