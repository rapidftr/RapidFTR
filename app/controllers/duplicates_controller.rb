class DuplicatesController < ApplicationController
  before_filter :current_user
  before_filter :administrators_only  
  
  def new    
    @child = Child.get params[:child_id]
    redirect_to :controller => :children, :action => :suspect_records and return if @child.nil?
    
    @page_name = "Mark #{@child.name} as Duplicate"
    @highlighted_fields = FormSection.sorted_highlighted_fields
  end
  
  def create
    @child = Child.get params[:child_id]
    @child.mark_as_duplicate params[:parent_id]
    @child.save
    
    redirect_to @child
  end
end
