class Children::SummariesController < ApplicationController
  def new
    
  end

  def create
    SearchRequest.new(params[:search_request])
    redirect_to children_summary_path
  end

  def show

  end
end
