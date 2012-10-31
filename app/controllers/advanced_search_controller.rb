class AdvancedSearchController < ApplicationController

  def new
    @forms = FormSection.by_order
    @aside = 'shared/sidebar_links'
    @page_name = "Advanced Search"
    @criteria_list = [SearchCriteria.new]
    @user = current_user
    @results = []
    prepare_params_for_limited_access_user(@user) unless can? :view_all, Child
    render :index
  end

  def index
    @page_name = "Advanced Search"
    @forms = FormSection.by_order
    @aside = 'shared/sidebar_links'
    @user = current_user
    prepare_params_for_limited_access_user(@user) unless can? :view_all, Child
    new_search = !params[:criteria_list]
    if new_search
      @criteria_list = [SearchCriteria.new]
      @results = []
    else
      @criteria_list = (child_fields_selected?(params[:criteria_list]) ? SearchCriteria.build_from_params(params[:criteria_list]) : [])
      @criteria_list = add_search_filters(params)
      @results = SearchService.search(@criteria_list)
      @criteria_list = add_search_criteria_if_none(params)
    end
  end

  def child_fields_selected? criteria_list
    !criteria_list.first[1]["field"].blank? if !criteria_list.first[1].nil?
  end

  private

  def add_search_filters params
    add_created_by_filter params
    add_updated_by_filter params
    add_created_at_filter params
    add_updated_at_filter params
    @criteria_list
  end

  def add_created_by_filter params
    @criteria_list.push(SearchFilter.new({:field => "created_by",
                                          :field2 => "created_by_full_name",
                                          :value => params[:created_by_value],
                                          :index => 1,
                                          :join => "AND"})) if !self.class.nil_or_empty(params, :created_by_value)
  end

  def add_updated_by_filter params
    @criteria_list.push(SearchFilter.new({:field => "last_updated_by",
                                          :field2 => "last_updated_by_full_name",
                                          :value => params[:updated_by_value],
                                          :index => 2,
                                          :join => "AND"})) if !self.class.nil_or_empty(params, :updated_by_value)
  end

  def add_created_at_filter params
    @criteria_list.push(SearchDateFilter.new({:field => "created_at",
                                              :from_value => (self.class.nil_or_empty(params, :created_at_after_value) ? "*" : "#{params[:created_at_after_value]}T00:00:00Z"),
                                              :to_value => (self.class.nil_or_empty(params, :created_at_before_value) ? "*" : "#{params[:created_at_before_value]}T00:00:00Z"),
                                              :index => 1,
                                              :join => "AND"})) if (!self.class.nil_or_empty(params, :created_at_after_value) || !self.class.nil_or_empty(params, :created_at_before_value))
  end

  def add_updated_at_filter params
    @criteria_list.push(SearchDateFilter.new({:field => "last_updated_at",
                                              :from_value => (self.class.nil_or_empty(params, :updated_at_after_value) ? "*" : "#{params[:updated_at_after_value]}T00:00:00Z"),
                                              :to_value => (self.class.nil_or_empty(params, :updated_at_before_value) ? "*" : "#{params[:updated_at_before_value]}T00:00:00Z"),
                                              :index => 2,
                                              :join => "AND"})) if (!self.class.nil_or_empty(params, :updated_at_after_value) || !self.class.nil_or_empty(params, :updated_at_before_value))
  end

  def add_search_criteria_if_none params
    @criteria_list.push(SearchCriteria.new) if !child_fields_selected?(params[:criteria_list])
    @criteria_list
  end

  def self.nil_or_empty params, key
    params[key].nil? || params[key].empty?
  end

  def prepare_params_for_limited_access_user user
    params[:created_by_value] = user.user_name
    params[:created_by] = "true"
    params[:disable_create] = "true"
  end

end
