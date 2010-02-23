class Children::SummariesController < ApplicationController
  def new
    
  end

  def create
    search_request = SearchRequest.create_search(ApplicationController.current_user.user_name, params[:search_params])
    search_request.save
    redirect_to children_summary_path
  end

  def show
    search_params = SearchRequest.get(ApplicationController.current_user.user_name)
    @results = Summary.basic_search(search_params[:user_name], search_params[:child_name])
  end
end