class AdvancedSearchController < ApplicationController

  def index 
    @forms = FormSection.all
    
    if params[:criteria_list]
      @criteria_list = SearchCriteria.build_from_params params[:criteria_list]      
      @results = SearchService.search(@criteria_list)
    else
      @criteria_list = [SearchCriteria.new]
      @results = []
    end
    
  end
end