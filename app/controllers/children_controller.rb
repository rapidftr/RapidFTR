class ChildrenController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :check_authentication, :only => [:reindex]

  before_action :load_child_or_redirect, :only => [:show, :edit, :destroy, :edit_photo, :update_photo]
  before_action :current_user, :except => [:reindex]
  before_action :sanitize_params, :only => [:update, :sync_unverified]

  def reindex
    Child.reindex!
    Enquiry.reindex!
    Enquiry.delay.update_all_child_matches
    render :nothing => true
  end

  # GET /children
  # GET /children.xml
  def index
    authorize! :index, Child

    @page_name = t('home.view_records')
    @aside = 'shared/sidebar_links'
    @filter = params[:filter] || nil
    @order = params[:order_by] || ChildrenHelper::ORDER_BY[@filter] || 'created_at'
    @sort_order = (params[:sort_order].nil? || params[:sort_order].empty?) ? :asc : params[:sort_order]
    per_page = params[:per_page] || ChildrenHelper::View::PER_PAGE
    per_page = per_page == 'all' ? Child.count : per_page.to_i
    page = params[:page] || 1

    search = Search.for(Child).
      paginated(page, per_page).
      ordered(@order, @sort_order.to_sym).
      marked_as(@filter)
    search.created_by(current_user) unless can?(:view_all, Child)
    @children = search.results

    @form_sections = form_sections
    @system_fields = Child.default_child_fields + Child.build_date_fields_for_solar

    respond_to do |format|
      format.html
      format.xml { render :xml => @children }
      unless params[:format].nil?
        if @children.empty?
          flash[:notice] = t('child.export_error')
          redirect_to(:action => :index) && return
        end
      end

      respond_to_export format, @children
    end
  end

  # GET /children/1
  # GET /children/1.xml
  def show
    authorize! :read, @child if @child['created_by'] != current_user_name
    @form_sections = form_sections
    @page_name = t 'child.view', :short_id => @child.short_id
    @body_class = 'profile-page'
    @duplicates = Child.by_duplicate_of(:key => params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => @child }
      format.json { render :json => @child.without_internal_fields }

      respond_to_export format, [@child]
    end
  end

  # GET /children/new
  # GET /children/new.xml
  def new
    authorize! :create, Child

    @page_name = t('children.register_new_child')
    @child = Child.new
    @form_sections = form_sections
    respond_to do |format|
      format.html
      format.xml { render :xml => @child }
    end
  end

  # GET /children/1/edit
  def edit
    authorize! :update, @child

    @page_name = t('child.edit')
    @form_sections = form_sections
  end

  # POST /children
  # POST /children.xml
  def create
    authorize! :create, Child
    params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    create_or_update_child(params[:child])
    params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
    @child['created_by_full_name'] = current_user_full_name
    respond_to do |format|
      if @child.save
        flash[:notice] = t('child.messages.creation_success')
        format.html { redirect_to(@child) }
        format.xml { render :xml => @child, :status => :created, :location => @child }
        format.json do
          render :json => @child.without_internal_fields
        end
      else
        format.html do
          @form_sections = form_sections
          render :action => 'new'
        end
        format.xml { render :xml => @child.errors, :status => :unprocessable_entity }
      end
    end
  end

  def sync_unverified
    params[:child] = JSON.parse(params[:child]) if params[:child].is_a?(String)
    params[:child][:photo] = params[:current_photo_key] unless params[:current_photo_key].nil?
    if params[:child][:_id]
      child = Child.get(params[:child][:_id])
      child = child.update_with_attachments(params, current_user)
      child.save
      render :json => child.without_internal_fields
    else
      respond_to do |format|
        format.json do

          child = create_or_update_child(params[:child].merge(:verified => current_user.verified?))

          child['created_by_full_name'] = current_user_full_name
          if child.save
            render :json => child.without_internal_fields
          end
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
        render :json => child.without_internal_fields
      end

      format.html do
        @child = update_child_from params
        if @child.save
          flash[:notice] = I18n.t('child.messages.update_success')
          return redirect_to params[:redirect_url] if params[:redirect_url]
          redirect_to @child
        else
          @form_sections = form_sections
          render :action => 'edit'
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

    @page_name = t('child.edit_photo')
  end

  def update_photo
    authorize! :update, @child

    orientation = params[:child].delete(:photo_orientation).to_i
    if orientation != 0
      @child.rotate_photo(orientation)
      @child.updated_fields_for(current_user_name)
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

  # DELETE /children/1
  # DELETE /children/1.xml
  def destroy
    authorize! :destroy, @child
    @child.destroy

    respond_to do |format|
      format.html { redirect_to(children_url) }
      format.xml { head :ok }
      format.json { render :json => {:response => 'ok'} }
    end
  end

  private

  def child_short_id(child_params)
    child_params[:short_id] || child_params[:unique_identifier].last(7)
  end

  def create_or_update_child(child_params)
    @child = Child.by_short_id(:key => child_short_id(child_params)).first if child_params[:unique_identifier]
    if @child.nil?
      @child = Child.new_with_user_name(current_user, child_params)
    else
      @child = update_child_from(params)
    end
  end

  def sanitize_params
    child_params = params['child']
    child_params['histories'] = JSON.parse(child_params['histories']) if child_params && child_params['histories'].is_a?(String) # histories might come as string from the mobile client.
  end

  def form_sections
    FormSection.enabled_by_order_for_form(Child::FORM_NAME)
  end

  def load_child_or_redirect
    @child = Child.get(params[:id])
    return unless @child.nil?
    respond_to do |format|
      format.json { render :json => @child }
      format.html do
        flash[:error] = 'Child with the given id is not found'
        redirect_to(:action => :index) && return
      end
    end
  end

  def update_child_from(params)
    child = @child || Child.get(params[:id]) || Child.new_with_user_name(current_user, params[:child])
    authorize! :update, child
    child.update_with_attachments(params, current_user)
    child
  end

  def respond_to_export(format, children)
    RapidftrAddon::ExportTask.active.each do |export_task|
      format.any(export_task.id) do
        authorize! "export_#{export_task.id}".to_sym, Child
        LogEntry.create! :type => LogEntry::TYPE[export_task.id], :user_name => current_user.user_name, :organisation => current_user.organisation, :child_ids => children.map(&:id)
        results = export_task.new.export(children)
        encrypt_exported_files results, export_filename(children, export_task)
      end
    end
  end

  def export_filename(children, export_task)
    (children.length == 1 ? children.first.short_id : current_user_name) + '_' + export_task.id.to_s + '.zip'
  end
end
