class Children::SummariesController < ApplicationController
  def new
    
  end

  def create
    search_request = SearchRequest.new(ApplicationController.current_user.user_name, params[:search_request])
    search_request.save
    redirect_to children_summary_path
  end

  def show

  end
end
