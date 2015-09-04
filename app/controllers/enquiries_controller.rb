class EnquiriesController < ApplicationController
  before_action :check_enquiry_feature_status
  before_action :load_enquiry, :only => [:show, :edit, :update]
  before_action :current_user, :except => [:reindex]
  skip_before_action :check_authentication, :only => [:reindex]
  def reindex
    Child.reindex!
    Enquiry.reindex!
    Enquiry.delay.update_all_child_matches
    render :nothing => true
  end

  # GET /children
  # GET /children.xml

  def index
    authorize! :index, Enquiry

    @page_name = t('home.view_records')
    @filter = params[:filter] || nil
    per_page = params[:per_page] || EnquiriesHelper::View::PER_PAGE
    per_page = per_page == 'all' ? Enquiry.count : per_page.to_i
    page = params[:page] || 1

    search = Search.for(Enquiry).
        paginated(page, per_page).
        marked_as(@filter)

    @enquiries = search.results
    flash[:notice] = t('enquiry.no_records_available') if @enquiries.empty?
    respond_to do |format|
      format.html
      format.xml { render :xml => @enquiries }
      unless params[:format].nil?
        if @enquiries.empty?
          flash[:notice] = t('enquiry.export_error')
          redirect_to(:action => :index) && return
        end
      end

      respond_to_export format, @enquiries
    end
  end

  def new
    @enquiry = Enquiry.new
    @form_sections = enquiry_form_sections

    respond_to do |format|
      format.html
      format.xml { render :xml => @enquiry }
    end
  end

  def create
    authorize! :create, Enquiry
    @enquiry = Enquiry.new_with_user_name current_user, params[:enquiry]

    if @enquiry.save
      flash[:notice] = t('enquiry.messages.creation_success')
      redirect_to(@enquiry)
    else
      @form_sections = enquiry_form_sections
      render :new
    end
  end

  def edit
    authorize! :update, Enquiry
    @form_sections = enquiry_form_sections
  end

  def update
    authorize! :update, Enquiry

    if @enquiry.update_attributes(params[:enquiry])
      flash[:notice] = t('enquiry.messages.update_success')
      redirect_to enquiry_path(@enquiry)
    else
      @form_sections = enquiry_form_sections
      render :edit
    end
  end

  def show
    authorize! :read, Enquiry
    @enquiry = Enquiry.find params[:id]
    @form_sections = enquiry_form_sections
  end

  def matches
    @filter = params[:filter] || nil
    @order = params[:order_by] || EnquiriesHelper::ORDER_BY[@filter] || 'created_at'
    @sort_order = (params[:sort_order].nil? || params[:sort_order].empty?) ? :asc : params[:sort_order]
    per_page = params[:per_page] || EnquiriesHelper::View::PER_PAGE
    page = params[:page] || 1

    @enquiries = Enquiry.with_child_potential_matches(:per_page => per_page, :page => page)

    render :template => 'enquiries/index_with_potential_matches'
  end

  private

  def load_enquiry
    @enquiry = Enquiry.find params[:id]
  end

  def enquiry_form_sections
    FormSection.enabled_by_order_for_form(Enquiry::FORM_NAME)
  end

  def check_enquiry_feature_status
    enquiries_enabled = SystemVariable.find_by_name(SystemVariable::ENABLE_ENQUIRIES)
    unless enquiries_enabled.nil? || enquiries_enabled.to_bool_value
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
      return false
    end
  end

  def respond_to_export(format, enquiries)
    RapidftrAddon::ExportTask.active.each do |export_task|
      format.any(export_task.id) do
        authorize! "export_#{export_task.id}".to_sym, Enquiry
        LogEntry.create! :type => LogEntry::TYPE[export_task.id], :user_name => current_user.user_name, :organisation => current_user.organisation, :enquiry_ids => enquiries.map(&:id)
        results = export_task.new.export(enquiries)
        encrypt_exported_files results, export_filename(enquiries, export_task)
      end
    end
  end

  def export_filename(enquiries, export_task)
    (enquiries.length == 1 ? enquiries.first.short_id : current_user_name) + '_' + export_task.id.to_s + '.zip'
  end
end
