class UserHistoriesController < ApplicationController
  helper :histories
  helper :children

  def index
    @user = User.get(params[:id])
    @page_name = t "user.history_of", :user_name => @user.user_name

    children = Child.all_connected_with(@user.user_name)
    unsorted = children.map{ |child| child.histories.map{ |history| history.merge(:child_id => child.id) } }.flatten
    @histories = unsorted.sort { |that, this| DateTime.parse(this["datetime"]) <=> DateTime.parse(that["datetime"]) }
    @histories.reject!{ |history| history["user_name"]!= @user.user_name }
  end
end
