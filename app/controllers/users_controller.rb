class UsersController < ApplicationController

  before_filter :administrators_only

  def index
    @users = User.view("by_full_name")
  end

  def show
    @user = User.get(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.get(params[:id])
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
    @user = User.get(params[:id])
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

end
