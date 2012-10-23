class UsersController < ApplicationController

  before_filter :administrators_only, :except =>[:show, :edit, :update]
  before_filter :clean_role_names, :only => [ :update, :create ]

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
    @roles = Role.all
  end

  def edit
    session = app_session
    @user = User.get(params[:id])
    @page_name = "Account: #{@user.full_name}"
    @roles = Role.all
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
      @roles = Role.all
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
      @roles = Role.all
      render :action => "edit"
    end
  end

  def destroy
    @user = User.get(params[:id])
    @user.destroy
    redirect_to(users_url)
  end

  private

  def clean_role_names
    params[:user][:role_names] = clean_params(params[:user][:role_names]) if params[:user][:role_names]
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
