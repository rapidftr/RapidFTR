class Api::EnquiriesController < Api::ApiController

  def create
    authorize! :create, Enquiry
    @enquiry = Enquiry.new(params[:enquiry])
    @enquiry.save!

  end


end
