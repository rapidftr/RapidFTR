class Api::EnquiriesController < Api::ApiController

  before_filter :sanitize_params, :only => [:update, :create]

  def create
    authorize! :create, Enquiry
    unless Enquiry.get(params['enquiry'][:id]).nil? then
      render_error("errors.models.enquiry.create_forbidden", 403) and return
    end

    @enquiry = Enquiry.new_with_user_name(current_user, params['enquiry'])

    unless @enquiry.valid? then
      render :json => {:error => @enquiry.errors.full_messages}, :status => 422 and return
    end

    @enquiry.save
    render :json => @enquiry, :status => 201
  end

  def update
    authorize! :update, Enquiry
    @enquiry = Enquiry.get(params[:id])
    if @enquiry.nil? then
      render_error("errors.models.enquiry.not_found", 404) and return
    end

    @enquiry.update_from(params['enquiry'])

    unless @enquiry.valid? then
      render :json => {:error => @enquiry.errors.full_messages}, :status => 422 and return
    end

    @enquiry.save
    render :json => @enquiry
  end

  def index
    authorize! :index, Enquiry
    render :json => Enquiry.all
  end

  def show
    authorize! :show, Enquiry
    enquiry = Enquiry.get (params[:id])
    if !enquiry.nil?
      render :json => enquiry.compact
    else
      render :json => "", :status => 404
    end
  end

  private

  def render_error(message, status_code)
    render :json => {:error => I18n.t(message)}, :status => status_code
  end

  def sanitize_params
    begin
      super :enquiry
    rescue JSON::ParserError
      render :json => {:error => I18n.t("errors.models.enquiry.malformed_query")}, :status => 422
    end
  end

end
