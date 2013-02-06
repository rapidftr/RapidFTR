class ChildrenController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :load_child_or_redirect, :only => [:show, :edit, :destroy, :edit_photo, :update_photo]
  before_filter :current_user
  before_filter :sanitize_params, :only => [:update]

  include ChildrenHelper::Validations

  # GET /children
  # GET /children.xml
  def index
    authorize! :index, Child

    @page_name = t('home.view_records')
    status = params[:filter] || params[:status] || "all"

    filter_children_by status, params[:order_by]

    respond_to do |format|
      format.html
      format.xml { render :xml => @children }
      format.json do
        render :json => @children
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
    @child = Child.new_with_user_name(current_user, params[:child])
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
        child = Child.new_with_user_name(current_user, params[:child].merge(:verified => false))
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
      authorize! :export, Child

      password = params[:password]
      raise ErrorResponse.bad_request('You must enter password to encrypt the exported file') unless password
      @options = {:encryption_options => {:user_password => password, :owner_password => password}}

      results = results || [] # previous version handled nils - needed?

      results.each do |child|
        child['photo_url'] = child_photo_url(child, child.primary_photo_id) unless child.primary_photo_id.nil?
        child['audio_url'] = child_audio_url(child)
      end

      export_generator = ExportGenerator.new(encryption_options, results)
      csv_data = export_generator.to_csv
      send_data(csv_data.data, csv_data.options)
    end


    def filter_children_by filter_option, order
      children = find_children_by_user_access filter_option
      total_rows = children.count
      paginated_records = children.paginate(:page => params[:page], :per_page => ChildrenHelper::View::PER_PAGE)
      presenter = ChildrenPresenter.new(paginated_records, filter_option, order)
      @children =  paginated_collection presenter.children, total_rows
      @filter = presenter.filter
      @order = presenter.order
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
        @results = Child.search_by_created_user(@search, app_session.user_name)
      end
    end

    def update_child_from params
      child = Child.get(params[:id]) || Child.new_with_user_name(current_user, params[:child])
      authorize! :update, child

      child['last_updated_by_full_name'] = current_user_full_name
      new_photo = params[:child].delete("photo")
      new_photo = (params[:child][:photo] || "") if new_photo.nil?
      new_audio = params[:child].delete("audio")
      child.update_properties_with_user_name(current_user_name, new_photo, params["delete_child_photo"], new_audio, params[:child])
      child
    end
end
