class UsersController < ApplicationController

  before_filter :administrators_only, :except =>[:show, :edit, :update]
  before_filter :set_permissions_params, :only => [ :update, :create ]

  def index
    @users = User.view("by_full_name")
    @users_details = users_details
  end

  def show
    session = app_session
    @user = User.get(params[:id])
    if @user.nil?
      flash[:error] = "User with the given id is not found"
      redirect_to :action => :index and return
    end
    unless session.admin? or @user.user_name == current_user_name
      raise AuthorizationFailure.new('Not permitted to view page')
    end
  end

  def new
    @page_name = 'New User'
    @user = User.new
  end

  def edit
    session = app_session

    @user = User.get(params[:id])
    @page_name = "Account: #{@user.full_name}"
    unless session.admin? or @user.user_name == current_user_name
      raise AuthorizationFailure.new('Not permitted to view page')
    end
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
    session = app_session

    @user = User.get(params[:id])
    unless session.admin? or @user.user_name == current_user_name
      raise AuthorizationFailure.new('Not permitted to view page') unless session.admin?
    end

    unless session.admin?
      unless @user.user_assignable? params[:user]
        raise AuthorizationFailure.new('Not permitted to assign admin specific fields')
      end
    end
    if @user.update_attributes(params[:user])
      if request.xhr?
        render :text => "OK"
      else
        flash[:notice] = 'User was successfully updated.'
        redirect_to(@user)
      end
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

  def set_permissions_params
    permissions = []
    user = params[:user]

    permissions.push("limited") if user[:permission] == "Limited"
    permissions.push("unlimited") if user[:permission] == "Unlimited"
    permissions.push("admin") if user[:user_type] == "Administrator"

    user.delete(:permission)
    user.delete(:user_type)
    user[:permissions] = permissions
  end

  def users_details
    @users.map do |user|
      {
        :user_url  => user_url(:id => user),
        :user_name => user.user_name,
        :token     => form_authenticity_token
      }
    end
  end

end
