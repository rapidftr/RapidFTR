class Api::EnquiriesController < Api::ApiController

  before_filter :sanitise_params

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
    if @enquiry.nil?
      render_error("errors.models.enquiry.not_found", 404)
      return
    end

    @enquiry.update_from(params['enquiry'])

    unless @enquiry.valid? && !params['enquiry']['criteria'].empty?
      render :json => {:error => @enquiry.errors.full_messages}, :status => 422
      return
    end

    @enquiry.save
    render :json => @enquiry
  end

  def index
    authorize! :index, Enquiry
    if params[:updated_after].nil?
      enquiries = Enquiry.all
    else
      enquiries = Enquiry.search_by_match_updated_since(params[:updated_after])
    end
    render :json => enquiries.map { |enquiry|
      {:location => "#{request.scheme}://#{request.host}:#{request.port}#{request.path}/#{enquiry[:_id]}"}
    }
  end

  def show
    authorize! :show, Enquiry
    enquiry = Enquiry.get (params[:id])
    if !enquiry.nil?
      render :json => enquiry
    else
      render :json => "", :status => 404
    end
  end

  private

  def render_error(message, status_code)
    render :json => {:error => I18n.t(message)}, :status => status_code
  end

  def sanitise_params
    begin
      if !(params[:updated_after]).nil?
        DateTime.parse params[:updated_after]
      end
    rescue
      render :json => "Invalid request", :status => 422
    end
  end
end
