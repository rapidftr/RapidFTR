class Api::EnquiriesController < Api::ApiController

  before_filter :sanitize_params, :only => [:update, :create]

  def create
    authorize! :create, Enquiry
    unless Enquiry.get(params['enquiry'][:id]).nil? then render_error("errors.models.enquiry.create_forbidden", 403) and return end

    @enquiry = Enquiry.new_with_user_name(current_user, params['enquiry'])

    unless @enquiry.valid? then render_error("errors.models.enquiry.presence_of_criteria", 422) and return end

    @enquiry.save!
    render :json => @enquiry, :status => 201
  end

  def update
    authorize! :update, Enquiry
    @enquiry = Enquiry.get(params['enquiry'][:id])
    if @enquiry.nil? then render_error("errors.models.enquiry.not_found", 404) and return end

    @enquiry.update_from(params['enquiry'])

    unless @enquiry.valid? then render_error("errors.models.enquiry.presence_of_criteria", 422) and return end

    @enquiry.save
    render :json => @enquiry
  end

  private

    def render_error(error_message_key, status_code)
      render :json => {:error => I18n.t(error_message_key)}, :status => status_code
    end

    def sanitize_params
      super :enquiry
    end
end
