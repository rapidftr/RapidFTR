class ChildHistoriesController < ApplicationController
  helper :histories
  def index
    @child = Child.get(params[:id])
    @page_name = t 'child.history_of', :short_id => @child.short_id
    @user = User.find_by_user_name(current_user_name)
  end
end
