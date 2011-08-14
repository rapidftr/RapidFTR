class UserPreferencesController < ApplicationController

  def update
    @user = User.find_by_user_name(current_user_name)

    if @user.update_attributes(params[:user])
      flash[:notice] = 'Timezone was successfully updated.'
    end
    redirect_to root_path
  end
end
