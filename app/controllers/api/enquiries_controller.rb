class Api::EnquiriesController < Api::ApiController

  before_filter :sanitize_params, :only => [:update, :create]

  def create
    authorize! :create, Enquiry
    object = params[:enquiry]
    @enquiry = Enquiry.get(object[:id])
    if !@enquiry.nil?
      render :json => {:error => I18n.t("errors.models.enquiry.create_forbidden")}, :status => 403
      return
    end
    @enquiry = Enquiry.new_with_user_name(current_user, object)
    if !@enquiry.valid?
      render :json => {:error => I18n.t("errors.models.enquiry.presence_of_criteria")}, :status => 422
      return
    else
      @enquiry.save!
      render :json => @enquiry, :status => 201
    end
  end

  def update
    authorize! :update, Enquiry
    @enquiry = Enquiry.get(params[:enquiry][:id])
    if @enquiry.nil?
      render :json => {:error => "Not found"}, :status => 404
    else
      @enquiry.update_from(params[:enquiry])
      @enquiry.save
      render :json => @enquiry
    end
  end

  private

    def sanitize_params
      super :enquiry
    end

end
