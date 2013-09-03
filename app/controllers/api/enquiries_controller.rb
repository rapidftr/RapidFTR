class Api::EnquiriesController < Api::ApiController

  def create
    authorize! :create, Enquiry
    create_or_update_enquiry params[:enquiry]
    @enquiry.save!
    render :json => @enquiry
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
