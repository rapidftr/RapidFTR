class HistoriesController < ApplicationController
  helper :children
  def show
    @child = Child.get(params[:child_id])
    @page_name = t("history_of")+" #{@child}"
    @user = User.find_by_user_name(current_user_name)
  end
end
