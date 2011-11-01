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
      @criteria_list = (child_fields_selected?(params[:criteria_list]) ? SearchCriteria.build_from_params(params[:criteria_list]): [])
      @advanced_criteria_list = build_advanced_user_criteria(params[:created_by_value], params[:date_created_value])

      @results = SearchService.search(@criteria_list + @advanced_criteria_list)
    end
  end

  def child_fields_selected?(criteria_list)
     !criteria_list.first[1]["field"].blank? if !criteria_list.first[1].nil?
  end

  private
  def build_advanced_user_criteria(created_by_value, date_created_value)
    advanced_user_criteria = []
    
    advanced_user_criteria << SearchCriteria.create_advanced_criteria({:field => "created_by", :value => created_by_value, :index => 12}) if (created_by_value)
    advanced_user_criteria << SearchCriteria.create_advanced_criteria({:field => "created_at", :value => date_created_value, :index => 13}) if (date_created_value)

    advanced_user_criteria
  end
end
