class AdvancedSearchController < ApplicationController

  def new
    @forms = FormSection.by_order
    @page_name = t("navigation.advanced_search")
    @criteria_list = [SearchCriteria.new]
    @user = current_user
    @results = []
    prepare_params_for_limited_access_user(@user) unless can? :view_all, Child
    render :index
  end

  def index
    @page_name = t("navigation.advanced_search")
    @forms = FormSection.by_order

    @user = current_user
    prepare_params_for_limited_access_user(@user) unless can? :view_all, Child
    @criteria_list = []
    @criteria_list = (child_fields_selected?(params[:criteria_list]) ? SearchCriteria.build_from_params(params[:criteria_list]) : []) unless !params[:criteria_list]
    @criteria_list = add_search_filters(params)
    @results, @full_results = SearchService.search(params[:page] || 1, @criteria_list)
    @criteria_list = add_search_criteria_if_none(params)
  end

  def export_data
    authorize! :export, Child
    selected_records = Hash[params["selections"].to_a.sort_by { |k,v| k}].values || {} if params["all"] != "Select all records"
    selected_records = params["full_results"].split(/,/) if params["all"] == "Select all records"
    if selected_records.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end

    children = []
    selected_records.each do |child_id| children.push(Child.get(child_id)) end
    if params[:commit] == t("child.actions.export_to_photo_wall")
      export_photos_to_pdf(children, "#{file_basename}.pdf")
    elsif params[:commit] == t("child.actions.export_to_pdf")
      pdf_data = ExportGenerator.new(children).to_full_pdf
      send_pdf(pdf_data, "#{file_basename}.pdf")
    elsif params[:commit] == t("child.actions.export_to_csv")
      render_as_csv(children, "#{file_basename}.csv")
    end
  end

  def export_photos_to_pdf children, filename
    authorize! :export, Child

    pdf_data = ExportGenerator.new(children).to_photowall_pdf
    send_pdf(pdf_data, filename)
  end

  def file_basename(child = nil)
    prefix = child.nil? ? current_user_name : child.short_id
    user = User.find_by_user_name(current_user_name)
    "#{prefix}-#{Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')}"
  end

  def render_as_csv results, filename
    results = results || [] # previous version handled nils - needed?

    results.each do |child|
      child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless (child.primary_photo_id.nil? || child.primary_photo_id == "")
      child['audio_url'] = child_audio_url(child)
    end

    export_generator = ExportGenerator.new results
    csv_data = export_generator.to_csv
    send_csv(csv_data.data, csv_data.options)
  end

  def child_fields_selected? criteria_list
    if !criteria_list.nil?
      !criteria_list.first[1]["field"].blank? if !criteria_list.first[1].nil?
    end
  end

  private

  def add_search_filters params
    add_created_by_filter params
    add_updated_by_filter params
    add_created_at_filter params
    add_updated_at_filter params
    add_created_by_organisation_filter params
    @criteria_list
  end

  def add_created_by_organisation_filter params
    @criteria_list.push(SearchFilter.new({:field => "created_organisation",
                                          :value => params[:created_by_organisation_value],
                                          :index => 1,
                                          :join => "AND"})) if !self.class.nil_or_empty(params, :created_by_organisation_value)
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
