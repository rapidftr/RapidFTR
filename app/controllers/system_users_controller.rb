class SystemUsersController < ApplicationController
  before_action :load_user, :only => [:edit, :update, :destroy]

  def index
    authorize! :read, SystemUsers
    @page_name = t("home.manage_system_users")
    @users = SystemUsers.all
  end

  def new
    authorize! :create, SystemUsers

    @page_name = t("admin.create_system_user")
    @user = SystemUsers.new
  end

  def create
    authorize! :create, SystemUsers
    @user = SystemUsers.new(params[:system_users])
    if @user.save
      redirect_to system_users_path
    else
      render :action => :new
    end
  end

  def edit
    authorize! :update, SystemUsers
  end

  def update
    authorize! :update, SystemUsers
    if @user.update_attributes(params[:system_users])
      redirect_to system_users_path
    else
      render :action => :edit
    end
  end

  def destroy
    authorize! :destroy, SystemUsers
    @user.destroy
    redirect_to system_users_path
  end

  private

  def load_user
    @user = SystemUsers.get("org.couchdb.user:" + params[:id])
    if @user.nil? || params[:system_users].nil? ? false : @user.name != params[:system_users][:name]
      flash[:error] = t("user.messages.not_found")
      redirect_to(:action => :edit) && return
    end
  end
end
