class DuplicatesController < ApplicationController
  before_filter :current_user
  before_filter :administrators_only  
  
  def new    
    @child = Child.get params[:child_id]
    redirect_to child_filter_path("flagged") and return if @child.nil?
    
    @page_name = "Mark #{@child.name} as Duplicate"
  end
  
  def create
    @child = Child.get params[:child_id]
    @child.mark_as_duplicate params[:parent_id]
    @child.save
    
    redirect_to @child
  end
end
