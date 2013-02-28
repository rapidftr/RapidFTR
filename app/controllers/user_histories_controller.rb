class UserHistoriesController < ApplicationController

  def index
    @user = User.get(params[:id])
    @page_name = t("history_of")+" #{@user.user_name} " + t("user.actions")

    children = Child.all_connected_with(@user.user_name)
    unsorted = children.map{|child| child.histories}.flatten
    @histories = unsorted.sort { |that, this| DateTime.parse(this["datetime"]) <=> DateTime.parse(that["datetime"])}
  end
end
