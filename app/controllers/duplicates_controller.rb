class DuplicatesController < ApplicationController
  def new
    @child = Child.get params[:child_id]
    authorize! :update, @child

    redirect_to child_filter_path("flagged") and return if @child.nil?
    @page_name = t("child.mark_as_duplicate_with_param", :child_name => @child.name)
  end

  def create
    @child = Child.get params[:child_id]
    authorize! :update, @child

    @child.mark_as_duplicate params[:parent_id]
    render :new and return unless @child.save
    redirect_to @child
  end
end
