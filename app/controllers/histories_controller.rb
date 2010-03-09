class HistoriesController < ApplicationController
  
  def show
    @child = Child.get(params[:child_id])
  end
end