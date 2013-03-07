class UserHistoriesController < ApplicationController
  helper :histories
  helper :children

  def index
    @user = User.get(params[:id])
    @page_name = t("history_of")+" #{@user.user_name} " + t("actions")

    children = Child.all_connected_with(@user.user_name)
    unsorted = children.map{|child| child.histories.map{|history| history.merge(:child_id => child.id, :child_name => child.name)}}.flatten
    @histories = unsorted.sort { |that, this| DateTime.parse(this["datetime"]) <=> DateTime.parse(that["datetime"])}
    @histories.reject!{|history| history["user_name"]!= @user.user_name}
  end
end
