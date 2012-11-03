class UsersController < ApplicationController

  before_filter :clean_role_ids, :only => [:update, :create]
  before_filter :load_user, :only => [:show, :edit, :update, :destroy]

  def index
    authorize! :read, User
    sort_option = params[:sort] || "full_name"
    @users = User.view("by_#{sort_option}")
    @users_details = users_details

    if params[:ajax] == "true"
      render :partial => "users/user", :collection => @users
    end
  end

  def show
    authorize! :show, User unless @user.user_name == current_user.user_name
  end

  def new
    authorize! :create, User
    @page_name = 'New User'
    @user = User.new
    @roles = Role.all
  end

  def edit
    authorize! :edit, User unless @user.user_name == current_user.user_name
    @page_name = "Account: #{@user.full_name}"
    @roles = Role.all
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
    authorize! :update, User unless @user.user_name == current_user.user_name
    raise_authorization_exception('Not permitted to assign role names') if illegal_access_to_role_ids?
    raise_authorization_exception('Not permitted to assign admin specific fields') if illegal_access_to_disable_flag?

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
    authorize! :destroy, User
    @user.destroy
    redirect_to(users_url)
  end

  private
  def load_user
    @user = User.get(params[:id])
    if @user.nil?
      flash[:error] = "User with the given id is not found"
      redirect_to :action => :index and return
    end
  end

  def clean_role_ids
    params[:user][:role_ids] = clean_params(params[:user][:role_ids]) if params[:user][:role_ids]
  end

  def users_details
    @users.map do |user|
      {
          :user_url =>  user_url(:id => user),
          :user_name => user.user_name,
          :token =>     form_authenticity_token
      }
    end
  end

  def illegal_access_to_role_ids?
    cannot?(:update, User) and @user.has_role_ids? params[:user]
  end

  def illegal_access_to_disable_flag?
    cannot?(:update_disable_flag, User) and @user.has_disable_field? params[:user]
  end

  def raise_authorization_exception(message)
    raise AuthorizationFailure.new(message)
  end

end
