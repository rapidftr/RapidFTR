class HistoriesController < ApplicationController

  def show
    @child = Child.get(params[:child_id])
    @page_name = "History of #{@child}"
  end
end