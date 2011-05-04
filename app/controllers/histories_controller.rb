class HistoriesController < ApplicationController

  def show
    @child = Child.get(params[:child_id])
    @photo_fields = FormSection.all_photo_field_names
    @page_name = "History of #{@child}"
  end
end