class ChildHistoriesController < ApplicationController
  helper :histories
  def index
    @child = Child.get(params[:id])
    @page_name = t("history_of")+" #{@child}"
    @user = User.find_by_user_name(current_user_name)
  end
end
