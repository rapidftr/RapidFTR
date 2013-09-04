class Api::EnquiriesController < Api::ApiController

  before_filter :sanitize_params, :only => [:update, :create]

  def create
    authorize! :create, Enquiry
    object = params[:enquiry]
    @enquiry = Enquiry.get(object[:id])
    if @enquiry.nil?
      @enquiry = Enquiry.new(object)
      @enquiry.save!
      render :json => @enquiry
    else
      render :json => {:error => "Forbidden"}, :status => 403
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
