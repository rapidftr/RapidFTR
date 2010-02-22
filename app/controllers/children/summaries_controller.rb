class Children::SummariesController < ApplicationController
  def new
    
  end

  def create
    search_request = SearchRequest.create_search(ApplicationController.current_user.user_name, params[:search_request])
    search_request.save
    redirect_to children_summary_path
  end

  def show
    search_params = SearchRequest.get(ApplicationController.current_user.user_name)
    @results = SummariesHelper.get_results(search_params)
  end
end
