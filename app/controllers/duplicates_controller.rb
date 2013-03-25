class DuplicatesController < ApplicationController
  def new
    @child = Child.get params[:child_id]
    authorize! :update, @child

    redirect_to child_filter_path("flagged") and return if @child.nil?
    @page_name = t("child.mark_child_as_duplicate", :short_id => @child.short_id)
  end

  def create
    @child = Child.get params[:child_id]
    authorize! :update, @child

    @child.mark_as_duplicate params[:parent_id]
    render :new and return unless @child.save
    redirect_to @child
  end
end
