class EnquiryHistoriesController < ApplicationController
  helper :histories
  def index
    @enquiry = Enquiry.get(params[:id])
    @page_name = t 'enquiry.history_of', :short_id => @enquiry.short_id
    @user = User.find_by_user_name(current_user_name)
  end
end
