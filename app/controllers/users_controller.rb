class UsersController < ApplicationController

  before_filter :clean_role_ids, :only => [:update, :create]
  before_filter :load_user, :only => [:show, :edit, :update, :destroy]

  skip_before_filter :check_authentication, :only => :register_unverified

  protect_from_forgery :except => :register_unverified


  def index
    authorize! :read, User
    sort_option = params[:sort] || "full_name"
    filter_option=params[:filter] || "active"

    @users=User.view("by_#{sort_option}_filter_view", {:startkey => [filter_option], :endkey => [filter_option, {}]})
    @users_details = users_details

    if params[:ajax] == "true"
      render :partial => "users/user", :collection => @users
    end
  end

  def show
    authorize! :show, @user
  end

  def new
    authorize! :create, User
    @page_name = t("user.new")
    @user = User.new
    @roles = Role.all
  end

  def edit
    authorize! :update, @user
    @page_name = t("account")+": #{@user.full_name}"
    @roles = Role.all
  end

  def create
    authorize! :create, User
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = t("user.messages.created")
      redirect_to(@user)
    else
      @roles = Role.all
      render :action => "new"
    end
  end

  def update
    authorize! :disable, @user if params[:user].include?(:disabled)
    authorize! :update, @user  if params[:user].except(:disabled).present?

    if @user.update_attributes(params[:user])
      if request.xhr?
        render :text => "OK"
      else
        flash[:notice] = t("user.messages.updated")
        redirect_to(@user)
      end
    else
      @roles = Role.all
      render :action => "edit"
    end
  end

  def destroy
    authorize! :destroy, @user
    @user.destroy
    redirect_to(users_url)
  end

  def register_unverified
    respond_to do |format|
      format.json do 
        user = User.new(params[:user].merge(:verified => false, :role_ids => ["123"]))
        user.save
        render :json => {:response => "ok"}.to_json
      end
    end
  end

  private
  def write_to_log comment
    File.open("/Users/ambhalla/Desktop/log.txt", "w+") do |f|
      f.write comment
    end
  end

  def load_user
    @user = User.get(params[:id])
    if @user.nil?
      flash[:error] = t("user.messages.not_found")
      redirect_to :action => :index and return
    end
  end

  def clean_role_ids
    params[:user][:role_ids] = clean_params(params[:user][:role_ids]) if params[:user][:role_ids]
  end

  def users_details
    @users.map do |user|
      {
          :user_url => user_url(:id => user),
          :user_name => user.user_name,
          :token => form_authenticity_token
      }
    end
  end

end
