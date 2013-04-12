class ChildrenController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :check_authentication, :only => [:reindex]

  before_filter :load_child_or_redirect, :only => [:show, :edit, :destroy, :edit_photo, :update_photo, :export_photo_to_pdf]
  before_filter :current_user, :except => [:reindex]
  before_filter :sanitize_params, :only => [:update, :sync_unverified]

  def reindex
    Child.reindex!
    render :nothing => true
  end

  # GET /children
  # GET /children.xml
  def index
    authorize! :index, Child

    @page_name = t("home.view_records")
    @aside = 'shared/sidebar_links'
    @filter = params[:filter] || params[:status] || "all"
    @order = params[:order_by] || 'name'
    per_page = params[:per_page] || ChildrenHelper::View::PER_PAGE

    filter_children per_page

    respond_to do |format|
      format.html
      format.xml { render :xml => @children }
      format.csv do
        authorize! :export, Child
        render_as_csv @children
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
    authorize! :read, @child if @child["created_by"] != current_user_name
    @form_sections = get_form_sections
    @page_name = t "child.view", :short_id => @child.short_id
    @body_class = 'profile-page'
    @duplicates = Child.duplicates_of(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @child }

      format.csv do
        authorize! :export, Child
        render_as_csv([@child])
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
  def create
    authorize! :create, Child

    @child = Child.new_with_user_name(current_user, params[:child])
    @child['created_by_full_name'] = current_user_full_name

    if @child.save
      flash[:notice] = t('child.messages.creation_success')
      redirect_to @child
    else
      @form_sections = get_form_sections
      render :action => "new"
    end
  end

  def update
    @child = Child.get(params[:id])
    authorize! :update, @child

    @child.update_with_attachments(params, current_user)
    if @child.save
      flash[:notice] = I18n.t("child.messages.update_success")
      redirect_to(params[:redirect_url] || @child)
    else
      @form_sections = get_form_sections
      render :action => "edit"
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
        search_by_user_access(params[:page] || 1)
      else
        render :search
      end
    end
    default_search_respond_to
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

  private

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
        render_as_csv(@results) if @results
      end
    end
  end

  def render_as_csv results
    results = results || [] # previous version handled nils - needed?

    results.each do |child|
      child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless (child.primary_photo_id.nil? || child.primary_photo_id == "")
      child['audio_url'] = child_audio_url(child)
    end

    export_generator = ExportGenerator.new results
    csv_data = export_generator.to_csv
    send_csv(csv_data.data, csv_data.options)
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

  def filter_children(per_page)
    total_rows, children = children_by_user_access(@filter, per_page)
    @children = paginated_collection children, total_rows
  end

  def children_by_user_access(filter_option, per_page)
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
    Child.fetch_paginated(options, params[:page] || 1, per_page)
  end

  def paginated_collection instances, total_rows
    page = params[:page] || 1
    WillPaginate::Collection.create(page, ChildrenHelper::View::PER_PAGE, total_rows) do |pager|
      pager.replace(instances)
    end
  end

  def search_by_user_access(page_number = 1)
    if can? :view_all, Child
      @results, @full_results = Child.search(@search, page_number)
    else
      @results, @full_results = Child.search_by_created_user(@search, current_user_name, page_number)
    end
  end

end 
