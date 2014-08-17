class DuplicatesController < ApplicationController
  def new
    @child = Child.get params[:child_id]
    authorize! :update, @child
    form = Form.find_by_name(Child::FORM_NAME)
    @sorted_highlighted_fields = form.sorted_highlighted_fields

    redirect_to(child_filter_path("flagged")) && return if @child.nil?
    @page_name = t("child.mark_child_as_duplicate", :short_id => @child.short_id)
  end

  def create
    @child = Child.get params[:child_id]
    authorize! :update, @child
    form = Form.find_by_name(Child::FORM_NAME)
    @sorted_highlighted_fields = form.sorted_highlighted_fields

    @child.mark_as_duplicate params[:parent_id]
    render(:new) && return unless @child.save
    redirect_to @child
  end
end
