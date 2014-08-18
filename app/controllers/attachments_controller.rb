class AttachmentsController < ApplicationController
  def show
    child = Child.get(params[:child_id])
    attachment = child.media_for_key(params[:id])
    send_data(attachment.data.read,
              :type => attachment.content_type,
              :disposition => 'inline')
  end
end
