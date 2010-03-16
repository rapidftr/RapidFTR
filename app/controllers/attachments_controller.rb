class AttachmentsController < ApplicationController
  
  def show
    child = Child.get(params[:child_id])
    send_data(
      child.photo_for_key(params[:id]),
      :type => child['_attachments'][params[:id]]['content_type'],
      :disposition => 'inline')
  end
end