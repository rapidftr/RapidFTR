class UsersController < ApplicationController

  before_filter :administrators_only, :except =>[:show, :edit, :update]

  def index
    @users = User.view("by_full_name")
  end

  def show
   check_authorization
  end

  def new
    @user = User.new
  end

  def edit
    check_authorization
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to(@user) 
    else
      render :action => "new" 
    end
  end

  def update

    
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(@user)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @user = User.get(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
  private
  def check_authorization
    session = app_session
    @user = User.get(params[:id])
    unless session.admin? or @user.user_name == current_user_name
      raise AuthorizationFailure.new('Not permitted to view page') unless session.admin?
    end
  end
end
