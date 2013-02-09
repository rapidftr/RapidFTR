class ChildrenController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :load_child_or_redirect, :only => [:show, :edit, :destroy, :edit_photo, :update_photo, :export_photo_to_pdf, :set_exportable]
  before_filter :current_user
  before_filter :sanitize_params, :only => [:update]

  # GET /children
  # GET /children.xml
  def index
    authorize! :index, Child

    @page_name = t("home.view_all_children")
    status = params[:filter] || params[:status] || "all"
    @aside = 'shared/sidebar_links'

    @filter = status
    @order = params[:order_by] || 'name'

    filter_children

    respond_to do |format|
      format.html
      format.xml { render :xml => @children }
      format.csv do
        authorize! :export, Child
        render_as_csv @children, "all_records_#{file_name_date_string}.csv"
      end
      format.json do
        render :json => @children
      end
      format.pdf do
        authorize! :export, Child
        pdf_data = ExportGenerator.new(@children).to_full_pdf
        send_pdf(pdf_data, "#{file_basename}.pdf")
      end
    end
  end

  # GET /children/1
  # GET /children/1.xml
  def show
    authorize! :read, @child
    @form_sections = get_form_sections
    @page_name = t("child.view")+": #{@child}"
    @body_class = 'profile-page'
    @duplicates = Child.duplicates_of(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @child }

      format.json {
        render :json => @child.compact.to_json
      }
      format.csv do
        authorize! :export, Child
        render_as_csv([@child], current_user_name+"_#{file_name_datetime_string}.csv")
      end
      format.pdf do
        authorize! :export, Child
        pdf_data = ExportGenerator.new(@child).to_full_pdf
        send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
      end
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
    authorize! :create, Child

    @page_name = t("children.register_new_child")
    @child = Child.new
    @form_sections = get_form_sections
    respond_to do |format|
      format.html
      format.xml { render :xml => @child }
    end
  end

  # GET /children/1/edit
  def edit
    authorize! :update, @child

    @page_name = t("child.edit")
    @form_sections = get_form_sections
  end

  # POST /children
  # POST /children.xml
  def create
    authorize! :create, Child
    params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    create_or_update_child
    params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
    @child['created_by_full_name'] = current_user_full_name
    respond_to do |format|
      if @child.save
        flash[:notice] = t('child.messages.creation_success')
        format.html { redirect_to(@child) }
        format.xml { render :xml => @child, :status => :created, :location => @child }
        format.json {
          render :json => @child.compact.to_json
        }
      else
        format.html {
          @form_sections = get_form_sections
          render :action => "new"
        }
        format.xml { render :xml => @child.errors, :status => :unprocessable_entity }
      end
    end
  end

  def sync_unverified
    respond_to do |format|
      format.json do
        params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
        params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
        child = Child.new_with_user_name(current_user, params[:child].merge(:verified => current_user.verified?))
        child['created_by_full_name'] = current_user.full_name
        if child.save
          render :json => child.compact.to_json
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
        child = update_child_from params
        child.save
        render :json => child.compact.to_json
      end

      format.html do
        @child = update_child_from params
        if @child.save
          flash[:notice] = I18n.t("child.messages.update_success")
          return redirect_to params[:redirect_url] if params[:redirect_url]
          redirect_to @child
        else
          @form_sections = get_form_sections
          render :action => "edit"
        end
      end

      format.xml do
        @child = update_child_from params
        if @child.save
          head :ok
        else
          render :xml => @child.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  def edit_photo
    authorize! :update, @child

    @page_name = t("child.edit_photo")
  end

  def update_photo
    authorize! :update, @child

    orientation = params[:child].delete(:photo_orientation).to_i
    if orientation != 0
      @child.rotate_photo(orientation)
      @child.set_updated_fields_for current_user_name
      @child.save
    end
    redirect_to(@child)
  end

  # POST
  def select_primary_photo
    @child = Child.get(params[:child_id])
    authorize! :update, @child

    begin
      @child.primary_photo_id = params[:photo_id]
      @child.save
      head :ok
    rescue
      head :error
    end
  end

  def new_search
  end

  # DELETE /children/1
  # DELETE /children/1.xml
  def destroy
    authorize! :destroy, @child
    @child.destroy

    respond_to do |format|
      format.html { redirect_to(children_url) }
      format.xml { head :ok }
      format.json { render :json => {:response => "ok"}.to_json }
    end
  end

  def search
    authorize! :index, Child

    @page_name = t("search")
    if (params[:query])
      @search = Search.new(params[:query])
      if @search.valid?
        search_by_user_access
      else
        render :search
      end
    end
    default_search_respond_to
  end

  def export_data
    authorize! :export, Child

    selected_records = params["selections"] || {}
    if selected_records.empty?
      raise ErrorResponse.bad_request('You must select at least one record to be exported')
    end

    children = selected_records.sort.map { |index, child_id| Child.get(child_id) }

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

  def export_photo_to_pdf
    authorize! :export, Child
    pdf_data = ExportGenerator.new(@child).to_photowall_pdf
    send_pdf(pdf_data, "#{file_basename(@child)}.pdf")
  end

  # POST
  def set_exportable
    authorize! :update, @child

    @child.exportable = params[:exportable] ? true : false
    @child.save!

    redirect_to child_path(@child.id)
  end

  private

  def create_or_update_child
    @child = Child.by_short_id(:key => params[:child][:short_id]).first
    if @child.nil?
      @child = Child.new_with_user_name(current_user, params[:child])
    else
      @child = update_child_from(params)
    end
  end

    def file_basename(child = nil)
      prefix = child.nil? ? current_user_name : child.short_id
      user = User.find_by_user_name(current_user_name)
      "#{prefix}-#{Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')}"
    end

  def sanitize_params
    child_params = params['child']
    child_params['histories'] = JSON.parse(child_params['histories']) if child_params and child_params['histories'].is_a?(String) #histories might come as string from the mobile client.
  end

  def file_name_datetime_string
      user = User.find_by_user_name(current_user_name)
      Clock.now.in_time_zone(user.time_zone).strftime('%Y%m%d-%H%M')
    end

    def file_name_date_string
      user = User.find_by_user_name(current_user_name)
      Clock.now.in_time_zone(user.time_zone).strftime("%Y%m%d")
    end

    def get_form_sections
      FormSection.enabled_by_order
    end

    def default_search_respond_to
      respond_to do |format|
        format.html do
          if @results && @results.length == 1
            redirect_to child_path(@results.first)
          end
        end
        format.csv do
          render_as_csv(@results, 'rapidftr_search_results.csv') if @results
        end
      end
    end

    def render_as_csv results, filename
      results = results || [] # previous version handled nils - needed?

      results.each do |child|
        child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless (child.primary_photo_id.nil? || child.primary_photo_id == "")
        child['audio_url'] = child_audio_url(child)
      end

      export_generator = ExportGenerator.new results
      csv_data = export_generator.to_csv
      send_data(csv_data.data, csv_data.options)
    end

    def load_child_or_redirect
      @child = Child.get(params[:id])

      if @child.nil?
        respond_to do |format|
          format.json { render :json => @child.to_json }
          format.html do
            flash[:error] = "Child with the given id is not found"
            redirect_to :action => :index and return
          end
        end
      end
    end

    def filter_children
      total_rows, children = children_by_user_access(@filter)
      @children =  paginated_collection children, total_rows
    end

    def children_by_user_access(filter_option)
      keys = [filter_option]
      options = {:view_name => "by_all_view_#{params[:order_by] || 'name'}".to_sym}
      unless  can?(:view_all, Child)
        keys = [filter_option, current_user_name]
        options = {:view_name => "by_all_view_with_created_by_#{params[:order_by] || 'created_at'}".to_sym}
      end
      if ['created_at', 'reunited_at', 'flag_at'].include? params[:order_by]
        options.merge!({:descending => true, :startkey => [keys, {}].flatten, :endkey => keys})
      else
        options.merge!({:startkey => keys, :endkey => [keys, {}].flatten})
      end
      Child.fetch_paginated(options, params[:page] || 1, ChildrenHelper::View::PER_PAGE)
    end

    def paginated_collection instances, total_rows
      page = params[:page] || 1
      WillPaginate::Collection.create(page, ChildrenHelper::View::PER_PAGE, total_rows) do |pager|
        pager.replace(instances)
      end
    end

    def search_by_user_access
      if can? :view_all, Child
        @results = Child.search(@search)
      else
        @results = Child.search_by_created_user(@search, current_user_name)
      end
    end

    def update_child_from params
      child = @child || Child.get(params[:id]) || Child.new_with_user_name(current_user, params[:child])
      authorize! :update, child
      child['last_updated_by_full_name'] = current_user_full_name
      new_photo = params[:child].delete("photo")
      new_photo = (params[:child][:photo] || "") if new_photo.nil?
      new_audio = params[:child].delete("audio")
      child.update_properties_with_user_name(current_user_name, new_photo, params["delete_child_photo"], new_audio, params[:child])
      child
    end
end
