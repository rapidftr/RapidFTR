class UsersController < ApplicationController
  before_action :clean_role_ids, :only => [:update, :create]
  before_action :load_user, :only => [:show, :edit, :update, :destroy]

  skip_before_action :check_authentication, :set_locale, :only => :register_unverified

  def index
    authorize! :read, User

    @page_name = t("home.users")
    sort_option = params[:sort] || "full_name"
    filter_option = params[:filter] || "active"

    @users = User.view("by_#{sort_option}_filter_view", :startkey => [filter_option], :endkey => [filter_option, {}])
    @users_details = users_details

    if params[:ajax] == "true"
      render :partial => "users/user", :collection => @users
    end
  end

  def unverified
    authorize! :show, User
    @page_name = t("users.unverified")
    flash[:verify] = t('users.select_role')
    @users = User.all_unverified
  end

  def show
    @page_name = t("users.account_details")
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
    @page_name = t("account") + ": #{@user.full_name}"
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
    params[:verify] = !@user.verified?

    if @user.update_attributes(params[:user])
      verify_children if params[:verify]
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

  def change_password
    @change_password_request = Forms::ChangePasswordForm.new(:user => current_user)
  end

  def update_password
    @change_password_request = Forms::ChangePasswordForm.new params[:forms_change_password_form]
    @change_password_request.user = current_user
    if @change_password_request.execute
      respond_to do |format|
        format.html do
          flash[:notice] = t("user.messages.password_changed_successfully")
          redirect_to user_path(current_user.id)
        end
        format.json { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { render :change_password }
        format.json { render :nothing => true, :status => :bad_request }
      end
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
        params[:user] = JSON.parse(params[:user]) if params[:user].is_a?(String)
        return render(:json => {:response => "ok"}.to_json) unless User.find_by_user_name(params[:user]["user_name"]).nil?
        password = params[:user]["unauthenticated_password"]
        updated_params = params[:user].merge(:verified => false, :password => password, :password_confirmation => password)
        updated_params.delete("unauthenticated_password")
        user = User.new(updated_params)

        user.save!
        render :json => {:response => "ok"}.to_json
      end
    end
  end

  def contact
    render :ok
  end

  private

  def write_to_log(comment)
    File.open("/Users/ambhalla/Desktop/log.txt", "w+") do |f|
      f.write comment
    end
  end

  def verify_children
    children = Child.by_created_by :key => @user.user_name
    children.each do |child|
      child.verified = true
      child.save
    end
  end

  def load_user
    @user = User.get(params[:id])
    if @user.nil?
      flash[:error] = t("user.messages.not_found")
      redirect_to(:action => :index) && return
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
