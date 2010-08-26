class HistoriesController < ApplicationController
  
  def show
    @child = Child.get(params[:child_id])

    if (@child != nil)
      @page_name = "History of #{@child["name"]}"
    end
  end
end