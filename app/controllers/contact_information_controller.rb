class ContactInformationController < ApplicationController
  # GET /contact_information/Admininstrator/edit
  # GET /contact_information/Administrator/edit
  def edit
    @contact_information = ContactInformation.get_by_id(params[:id])
  end
  
end
