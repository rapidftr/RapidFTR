class ContactInformationController < ApplicationController
  # GET /contact_information/Admininstrator/edit
  # GET /contact_information/Administrator/edit
  def edit
    administrators_only
    @contact_information = ContactInformation.get_by_id(params[:id])
  end
  
end
