class AdvancedSearchController < ApplicationController

  def new
    @forms = FormSection.by_order
    @aside = 'shared/sidebar_links'
    @page_name = "Advanced Search"
    @criteria_list = [SearchCriteria.new]
    @advanced_criteria_list = []
    @results = []
    render :index
  end

  def index
    @page_name = "Advanced Search"
    @forms = FormSection.by_order
    @aside = 'shared/sidebar_links'
    @highlighted_fields = []
    @user = current_user
    new_search = !params[:criteria_list]

    if new_search
      @criteria_list = [SearchCriteria.new]
      @results = []
    else 
      search_criteria=[]

      if child_fields_selected?(params[:criteria_list])
        @criteria_list = SearchCriteria.build_from_params(params[:criteria_list])
        search_criteria += @criteria_list
      else
        @criteria_list = [SearchCriteria.new]
      end

      @advanced_criteria_list = build_advanced_user_criteria(params[:created_by_value], params[:updated_by_value])
      search_criteria += @advanced_criteria_list

      @results = SearchService.search(search_criteria)
      
      #filter results by date
      @results = SearchService.filter_by_date(@results, params[:created_at_start_value], params[:created_at_end_value], :created_at)  if params[:created_at_start_value]
      @results = SearchService.filter_by_date(@results, params[:last_updated_at_start_value], params[:last_updated_at_end_value], :last_updated_at) if params[:last_updated_at_start_value]
    end
  end

  def child_fields_selected?(criteria_list)
     !criteria_list.first[1]["field"].blank? if !criteria_list.first[1].nil?
  end

  private
  def build_advanced_user_criteria(created_by_value, updated_by_value)
    advanced_user_criteria = []
    advanced_user_criteria << SearchCriteria.create_advanced_criteria({:field => "created_by", :value => created_by_value, :index => 12}) if (created_by_value)
    advanced_user_criteria << SearchCriteria.create_advanced_criteria({:field => "last_updated_by", :value => updated_by_value, :index => 13}) if (updated_by_value)
    advanced_user_criteria
  end
end
