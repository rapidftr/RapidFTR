class Api::EnquiriesController < Api::ApiController

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


  private

    def create_or_update_enquiry(object)
      @enquiry = Enquiry.get(object[:id])
      if @enquiry.nil?
        @enquiry = Enquiry.new(object)
      else
        @enquiry.update_from(object)
      end
    end
end
