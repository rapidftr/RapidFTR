class UserHistoriesController < ApplicationController

  def index
    @user = User.get(params[:id])

    children = Child.all_connected_with(@user.user_name)
    unsorted = children.map{|child| child.histories}.flatten
    @histories = unsorted.sort { |that, this| DateTime.parse(this["datetime"]) <=> DateTime.parse(that["datetime"])}
  end
end
